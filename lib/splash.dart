import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.primary,
      body: Center(
        child: Image.asset("assets/logo.png", width: media.width*0.7, fit: BoxFit.fill,),
      ),
    );
  }
}
