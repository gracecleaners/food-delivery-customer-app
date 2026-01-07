import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controller/user_controller.dart';
import 'api_service.dart';

class NotificationService {
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

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase if not already done
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      // Get FCM token
      await _getFcmToken();

      // Configure message handlers
      await _configureMessageHandlers();

      _initialized = true;
      print('✅ Notification service initialized');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle local notification on iOS
      },
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }

    if (Platform.isAndroid) {
      // For Android 13+
      if (Platform.isAndroid) {
        final NotificationSettings settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('✅ Notification permissions granted');
        } else {
          print('❌ Notification permissions denied');
        }
      }
    }
  }

  Future<void> _getFcmToken() async {
    try {
      // Get the FCM token
      final token = await _firebaseMessaging.getToken();
      
      if (token != null) {
        _storage.write(fcmTokenKey, token);
        print('🔑 FCM Token: $token');
        
        // Register token with backend if user is logged in
        await _registerTokenWithBackend(token);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final userController = Get.find<UserController>();
      if (!userController.isLoggedIn) {
        print('⚠️ User not logged in, skipping token registration');
        return;
      }

      final apiService = Get.find<ApiService>();
      
      await apiService.post('users/auth/device/register/', {
        'registration_id': token,
        'type': Platform.isAndroid ? 'android' : 'ios',
        'name': '${Platform.operatingSystem} device',
      });

      print('✅ FCM token registered with backend');
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

    // Handle messages when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Background message tapped: ${message.notification?.title}');
      _handleMessage(message);
    });

    // Handle initial message when app is terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('📱 Initial message: ${initialMessage.notification?.title}');
      _handleMessage(initialMessage);
    }

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('🔄 FCM Token refreshed: $newToken');
      _storage.write(fcmTokenKey, newToken);
      await _registerTokenWithBackend(newToken);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Add to stream
    _notificationStreamController.add(message);
    
    // Show local notification
    _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final apple = message.notification?.apple;

    if (notification != null) {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'fudz_channel_id',
        'Fudz Notifications',
        channelDescription: 'Fudz app notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails();

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  }

  void _handleMessage(RemoteMessage message) {
    // Add to stream
    _notificationStreamController.add(message);
    
    // Handle navigation based on message data
    _handleNotificationTap(message.data.toString());
  }

  void _handleNotificationTap(String? payload) {
    try {
      if (payload == null) return;

      // Parse the data
      final data = Uri.splitQueryString(payload.replaceAll('{', '').replaceAll('}', ''));
      
      // Handle different notification types
      final type = data['type'];
      
      switch (type) {
        case 'order_approved':
          final orderId = data['order_id'];
          Get.toNamed('/order-details', arguments: {'orderId': orderId});
          break;
          
        case 'order_status':
          final orderId = data['order_id'];
          Get.toNamed('/order-details', arguments: {'orderId': orderId});
          break;
          
        case 'promotion':
          final promoId = data['promo_id'];
          Get.toNamed('/promotions', arguments: {'promoId': promoId});
          break;
          
        case 'general':
          Get.toNamed('/notifications');
          break;
          
        default:
          Get.toNamed('/home');
      }
    } catch (e) {
      print('❌ Error handling notification tap: $e');
    }
  }

  // Unregister device when user logs out
  Future<void> unregisterDevice() async {
    try {
      final token = _storage.read<String>(fcmTokenKey);
      if (token != null) {
        final apiService = Get.find<ApiService>();
        await apiService.delete('users/auth/device/unregister/', {
          'registration_id': token,
        });
        print('✅ Device unregistered from backend');
      }
      
      _storage.remove(fcmTokenKey);
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
    } else {
      await _getFcmToken();
    }
  }

  // Dispose resources
  void dispose() {
    _notificationStreamController.close();
  }
}