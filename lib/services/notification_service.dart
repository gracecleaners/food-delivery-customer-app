import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controller/user_controller.dart';
import 'api_service.dart';

class NotificationService extends GetxService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String fcmTokenKey = 'fcm_token';
  static const String notificationEnabledKey = 'notifications_enabled';

  final _storage = GetStorage();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin _localNotifications;

  // Stream controller for incoming notifications
  final _notificationStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get notificationStream => _notificationStreamController.stream;

  bool _initialized = false;
  String? _currentFcmToken;

  @override
  void onClose() {
    _notificationStreamController.close();
    super.onClose();
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔄 Initializing Notification Service...');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      // Get FCM token
      await _getFcmToken();

      // Configure message handlers
      await _configureMessageHandlers();

      _initialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  Future<void> _initializeLocalNotifications() async {
  _localNotifications = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    // onDidReceiveLocalNotification has been removed/renamed in newer versions
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await _localNotifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('📱 Notification tapped: ${response.payload}');
      _handleNotificationTap(response.payload);
    },
    // onDidReceiveBackgroundNotificationResponse is no longer needed
    // as onDidReceiveNotificationResponse handles both cases
  );

  // Create notification channel for Android
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fudz_channel_id',
      'Fudz Notifications',
      description: 'Fudz app notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  print('✅ Local notifications initialized');
}

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        print('📱 iOS notification permission status: ${settings.authorizationStatus}');
      }

      if (Platform.isAndroid && (Platform.version as int) >= 33) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        print('📱 Android 13+ notification permission status: ${settings.authorizationStatus}');
      }

      print('✅ Notification permissions requested');
    } catch (e) {
      print('⚠️ Error requesting notification permissions: $e');
    }
  }

  Future<void> _getFcmToken() async {
    try {
      // Get the FCM token
      final token = await _firebaseMessaging.getToken();
      
      if (token != null && token.isNotEmpty) {
        _currentFcmToken = token;
        _storage.write(fcmTokenKey, token);
        print('🔑 FCM Token obtained: ${token.substring(0, 20)}...');
        
        // Register token with backend if user is logged in
        await registerDevice();
      } else {
        print('⚠️ FCM token is null or empty');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  Future<void> registerDevice() async {
    try {
      final userController = Get.find<UserController>();
      if (!userController.isLoggedIn) {
        print('⚠️ User not logged in, skipping device registration');
        return;
      }

      if (_currentFcmToken == null || _currentFcmToken!.isEmpty) {
        print('⚠️ No FCM token available for registration');
        return;
      }

      final apiService = Get.find<ApiService>();
      
      final response = await apiService.post('users/auth/device/register/', {
        'registration_id': _currentFcmToken,
        'type': Platform.isAndroid ? 'android' : 'ios',
        'name': '${Platform.operatingSystem} device - ${DateTime.now()}',
      });

      print('✅ FCM token registered with backend: ${response['success']}');
    } catch (e) {
      print('❌ Error registering FCM token: $e');
    }
  }

  Future<void> _configureMessageHandlers() async {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Foreground message received: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Handle messages when app is in background (but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Background message tapped: ${message.notification?.title}');
      _handleMessage(message, fromBackground: true);
    });

    // Handle initial message when app is terminated and opened via notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('📱 Initial message from terminated state: ${initialMessage.notification?.title}');
      _handleMessage(initialMessage, fromTerminated: true);
    }

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
      _currentFcmToken = newToken;
      _storage.write(fcmTokenKey, newToken);
      await registerDevice();
    });

    // Setup foreground notification settings for iOS
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    print('✅ Message handlers configured');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Add to stream for UI updates
    _notificationStreamController.add(message);
    
    // Show local notification
    _showLocalNotification(message);
    
    // Handle any immediate actions
    _handleNotificationData(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      
      if (notification == null) {
        print('⚠️ No notification data in message');
        return;
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'fudz_channel_id',
        'Fudz Notifications',
        channelDescription: 'Fudz app notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        enableVibration: true,
        showWhen: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notification.title ?? 'Fudz Notification',
        notification.body ?? 'You have a new notification',
        platformChannelSpecifics,
        payload: message.data.toString(),
      );

      print('📱 Local notification shown: ${notification.title}');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  void _handleMessage(RemoteMessage message, {bool fromBackground = false, bool fromTerminated = false}) {
    // Add to stream
    _notificationStreamController.add(message);
    
    // Handle notification data
    _handleNotificationData(message.data, fromBackground: fromBackground);
  }

  void _handleNotificationData(Map<String, dynamic> data, {bool fromBackground = false}) {
    try {
      print('📱 Handling notification data: $data');
      
      final type = data['type'] ?? data['notification_type'];
      final orderId = data['order_id'];
      final restaurantId = data['restaurant_id'];
      final promoId = data['promo_id'];

      // Navigate based on notification type
      if (fromBackground || Get.currentRoute != '/home') {
        switch (type) {
          case 'order_approved':
          case 'order_status':
            if (orderId != null) {
              Get.toNamed('/order-details', arguments: {'orderId': orderId});
            }
            break;
            
          case 'restaurant_update':
            if (restaurantId != null) {
              Get.toNamed('/restaurant-details', arguments: {'restaurantId': restaurantId});
            }
            break;
            
          case 'promotion':
            if (promoId != null) {
              Get.toNamed('/promotions', arguments: {'promoId': promoId});
            }
            break;
            
          case 'general':
            Get.toNamed('/notifications');
            break;
            
          default:
            Get.toNamed('/home');
        }
      }
    } catch (e) {
      print('❌ Error handling notification data: $e');
    }
  }

  void _handleNotificationTap(String? payload) {
    try {
      if (payload == null || payload.isEmpty) return;

      print('📱 Notification tapped with payload: $payload');
      
      // Parse the data string (format: {key1: value1, key2: value2})
      final cleanedPayload = payload
          .replaceAll('{', '')
          .replaceAll('}', '')
          .replaceAll(' ', '');
      
      final pairs = cleanedPayload.split(',');
      final data = <String, dynamic>{};
      
      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          data[keyValue[0]] = keyValue[1];
        }
      }
      
      _handleNotificationData(data, fromBackground: true);
    } catch (e) {
      print('❌ Error parsing notification payload: $e');
    }
  }

 // Unregister device when user logs out
Future<void> unregisterDevice() async {
  try {
    final token = _storage.read<String>(fcmTokenKey);
    if (token != null && token.isNotEmpty) {
      final apiService = Get.find<ApiService>();
      await apiService.delete('users/auth/device/unregister/', data: {
        'registration_id': token,
      });
      print('✅ Device unregistered from backend');
    }
    
    _storage.remove(fcmTokenKey);
    _currentFcmToken = null;
  } catch (e) {
    print('❌ Error unregistering device: $e');
  }
}

  // Check if notifications are enabled
  bool areNotificationsEnabled() {
    return _storage.read<bool>(notificationEnabledKey) ?? true;
  }

  // Toggle notification settings
  Future<void> toggleNotifications(bool enabled) async {
    _storage.write(notificationEnabledKey, enabled);
    
    if (!enabled) {
      await unregisterDevice();
      await _firebaseMessaging.deleteToken();
      print('🔕 Notifications disabled');
    } else {
      await _getFcmToken();
      print('🔔 Notifications enabled');
    }
  }

  // Get current FCM token
  String? getFcmToken() {
    return _currentFcmToken ?? _storage.read<String>(fcmTokenKey);
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
    print('🗑️ All notifications cleared');
  }

  // Test notification sending
  Future<void> sendTestNotification() async {
    try {
      final apiService = Get.find<ApiService>();
      final userController = Get.find<UserController>();
      
      if (!userController.isLoggedIn) {
        Get.snackbar(
          'Error',
          'Please log in to send test notifications',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await apiService.post('users/auth/notification/test/', {
        'title': 'Test Notification',
        'message': 'This is a test notification from the app',
        'data': {
          'type': 'test',
          'test_id': '123',
          'timestamp': DateTime.now().toIso8601String(),
        }
      });
      
      Get.snackbar(
        'Success',
        'Test notification sent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send test notification: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}