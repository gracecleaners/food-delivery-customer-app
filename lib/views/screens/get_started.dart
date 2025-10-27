import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_customer/views/auth/login.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

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
                height: media.height * 0.15,
                width: media.width,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Welcome",
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Your Favorite Food, Delivered Fast!",
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: media.width * 0.9,
                height: media.height*0.06,
                child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                            ),
                            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                            },
                            child: const Text(
                "Get Started",
                style: TextStyle(fontSize: 18),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
