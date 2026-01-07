import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/cart_controller.dart';
import 'package:food_delivery_customer/controller/category_controller.dart';
import 'package:food_delivery_customer/controller/email_auth_controller.dart';
import 'package:food_delivery_customer/controller/location_controller.dart';
import 'package:food_delivery_customer/controller/order_controller.dart';
import 'package:food_delivery_customer/controller/restaurant_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/controller/wishlist_controller.dart';
import 'package:food_delivery_customer/controller/menu_controller.dart' as men;
import 'package:food_delivery_customer/routes/app_pages.dart';
import 'package:food_delivery_customer/services/api_service.dart';
import 'package:food_delivery_customer/services/google.dart';
import 'package:food_delivery_customer/services/notification_service.dart';
import 'package:food_delivery_customer/services/snackbar_service.dart';
import 'package:food_delivery_customer/splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:food_delivery_customer/services/token_service.dart';
import 'package:flutter/foundation.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await GetStorage.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Food Delivery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        useMaterial3: true,
      ),
      initialBinding: AppBindings(),
      home: const SplashScreen(),
      getPages: AppPages.routes,
      onInit: () async {
        // Initialize notification service after app starts
        await Get.find<NotificationService>().initialize();
        
        // Set up auth state listener for device registration
        final userController = Get.find<UserController>();
        userController.userObs.listen((user) async {
          final notificationService = Get.find<NotificationService>();
          if (user != null) {
            // User logged in, ensure device is registered
            await notificationService.registerDevice();
          } else {
            // User logged out, unregister device
            await notificationService.unregisterDevice();
          }
        });
      },
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Register services
    Get.lazyPut(() => ApiService(), fenix: true);
    // Ensure a single TokenService instance is registered at startup so all
    // controllers share the same token state.
    Get.put(TokenService(), permanent: true);
    Get.put(GoogleSignInService());
    Get.lazyPut(() => NotificationService(), fenix: true);

    // Register controllers
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => RestaurantController(), fenix: true);
    Get.lazyPut(() => CartController(), fenix: true);
    Get.lazyPut(() => CategoryController(), fenix: true);
    Get.lazyPut(() => WishlistController(), fenix: true);
    Get.lazyPut(() => OrderController(), fenix: true);
    Get.lazyPut(() => EmailAuthController(), fenix: true);
    Get.lazyPut(() => men.MenuItemController(), fenix: true);
    Get.lazyPut(() => LocationController(), fenix: true);
  }
}


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaJNLz-zkj6WvWiaNGzxDjGtopRY-_T40',
    appId: '1:788581837666:android:53b53bef29d99735321a3b',
    messagingSenderId: '788581837666',
    projectId: 'delivery-1d642',
    storageBucket: 'delivery-1d642.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'IOS_API_KEY',
    appId: 'IOS_APP_ID',
    messagingSenderId: 'SENDER_ID',
    projectId: 'PROJECT_ID',
    storageBucket: 'PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.yourapp',
  );
}
