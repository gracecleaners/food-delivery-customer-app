import 'package:food_delivery_customer/routes/app_routes.dart';
import 'package:food_delivery_customer/views/auth/email_login.dart';
import 'package:food_delivery_customer/views/auth/email_verification_screen.dart';
import 'package:food_delivery_customer/views/screens/Home_view/homescreen.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.EMAIL_LOGIN_SCREEN, page: () => EmailLoginScreen()),
    GetPage(
        name: Routes.EMAIL_VERIFICATION_SCREEN,
        page: () => EmailVerificationScreen()),
    GetPage(
        name: Routes.HOME,
        page: () => HomePage())
  ];
}
