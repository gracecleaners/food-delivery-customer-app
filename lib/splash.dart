import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/views/screens/get_started.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserController _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 3));

    // Check if user is logged in
    if (_userController.isLoggedIn) {
      print('=== USER IS LOGGED IN ===');
      print('Navigating to Home...');
      // User is logged in, go directly to home
      Get.offAllNamed('/home');
    } else {
      print('=== USER NOT LOGGED IN ===');
      print('Navigating to Get Started...');
      // User not logged in, go to get started
      Get.to(GetStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              width: media.width * 0.7,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}