import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/email_auth_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/views/auth/verify_wa.dart';
import 'package:food_delivery_customer/views/widgets/round_button.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                "assets/login_image.png",
                width: media.width,
                height: media.height,
                fit: BoxFit.cover,
              ),
            ],
          ),
          SingleChildScrollView(
            child: SafeArea(
                child: Column(
              children: [
                SizedBox(
                  height: media.width * 0.8,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "WELCOME TO FUDZ",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: TColor.primary),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Get your favorite meals delivered fast – start with your phone number!",
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.6)),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: const Text(
                                "+256",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const VerticalDivider(width: 1, color: Colors.grey),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 12),
                                  hintText: "Enter phone number",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PhoneVerificationWaPage()));
                          },
                          child: Text(
                            "Get Code",
                            style: TextStyle(color: TColor.primary),
                          ))),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                          endIndent: 10,
                        ),
                      ),
                      Text(
                        "Start with socials",
                        style: TextStyle(color: Colors.black.withOpacity(0.7)),
                      ),
                      const Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                          indent: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RoundButton(
                    title: "Start with Google",
                    onPressed: () {},
                    bgcolor: Colors.redAccent,
                    color1: Colors.white,
                    icon: FontAwesomeIcons.google,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RoundButton(
                    title: "Start with Email",
                    onPressed: () {
                      Get.put(UserController());
                      Get.toNamed('/email_login_screen');
                    },
                    bgcolor: TColor.primary,
                    color1: TColor.primary,
                    icon: Icons.email,
                    isOutlined: true,
                  ),
                ),
              ],
            )),
          )
        ],
      ),
    );
  }
}
