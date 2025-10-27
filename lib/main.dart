import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/email_auth_controller.dart';
import 'package:food_delivery_customer/controller/restaurant_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/routes/app_pages.dart';
import 'package:food_delivery_customer/splash.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        useMaterial3: true,
      ),
      initialBinding: AppBindings(),
      home: const SplashScreen(),
      getPages: AppPages.routes,
      // home: CategoryPage(categoryName: "Fast Food"),
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController());
    Get.lazyPut(() => EmailAuthController());
    Get.put(RestaurantController());
  }
}
