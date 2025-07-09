import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/views/widgets/text_widget.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(
      children: [
        Image.asset(
          "assets/start_image.png",
          height: media.height,
          width: media.width,
          fit: BoxFit.cover,
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: media.height * 0.7,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
        ),

        // Logo at the bottom
        Positioned(
          bottom: media.height * 0.2,
          left: 0,
          right: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                "assets/logo.png",
                height: media.height * 0.1,
                width: media.width,
              ),
              Text(
                "Welcome",
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Get Started",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: TColor.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),)
            ],
          ),
        ),
      ],
    ));
  }
}
