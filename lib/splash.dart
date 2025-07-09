import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/views/screens/get_started.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    triggerNewScreen();
    super.initState();
  }

  void triggerNewScreen() async {
    await Future.delayed(Duration(seconds: 4));
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GetStarted()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.primary,
      body: Center(
        child: Image.asset(
          "assets/logo.png",
          width: media.width * 0.7,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
