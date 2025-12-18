import 'package:flutter/material.dart';
import 'package:food_delivery_customer/views/auth/email_login.dart';
import 'package:food_delivery_customer/views/auth/login.dart';
import 'package:food_delivery_customer/views/screens/google_phone_input.dart';
import 'package:food_delivery_customer/views/screens/register.dart';
import 'package:get/get.dart';
import 'package:food_delivery_customer/views/auth/email_verification_screen.dart';
import 'package:food_delivery_customer/views/screens/get_started.dart';
import 'package:food_delivery_customer/views/screens/main_tab/main_tab_view.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: '/get_started',
      page: () => const GetStarted(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginScreen(),
    ),
    GetPage(
      name: '/email_login_screen',
      page: () => const EmailLoginScreen(),
    ),
    GetPage(
      name: '/email_verification',
      page: () => const EmailVerificationScreen(),
    ),
    GetPage(
      name: '/register',
      page: () => RegistrationPage(),
    ),
    GetPage(
      name: '/home',
      page: () => const MainTabView(),
    ),
    // In your routes file
GetPage(
  name: '/google_phone_input',
  page: () {
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      return GooglePhoneInputScreen(googleUserData: arguments);
    }
    return const Scaffold(body: Center(child: Text('Invalid arguments')));
  },
),
  ];
}