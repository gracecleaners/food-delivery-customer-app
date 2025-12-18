// views/auth/login.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/views/screens/google_button.dart';
import 'package:food_delivery_customer/views/widgets/round_button.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: media.height,
        width: media.width,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                "assets/login_image.png",
                fit: BoxFit.cover,
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: media.width * 0.6),

                    // Welcome text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WELCOME TO FUDZ",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: TColor.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Get your favorite meals delivered fast – start with your phone number!",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Phone input section
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: const Text(
                              "+256",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const VerticalDivider(width: 1, color: Colors.grey),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 12,
                                ),
                                hintText: "Enter phone number",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Get Code button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        // Phone verification route not registered; disable the button
                        onPressed: null,
                        child: Text(
                          "Get Code",
                          style:
                              TextStyle(color: TColor.primary.withOpacity(0.5)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider with text
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Start with socials",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Google button - USING FIXED ROUNDBUTTON
                    // In login.dart, replace the Google button section with:

// Google button - U// In login.dart, the Google button is now functional:
                    Obx(() => GoogleSignInButton(
                          onPressed: userController.isLoading.value
                              ? null
                              : () async {
                                  try {
                                    await userController.signInWithGoogle();
                                  } catch (e) {
                                    // Error is already handled in controller
                                    print('Google Sign-In error in UI: $e');
                                  }
                                },
                          isLoading: userController.isLoading.value,
                        )),

                    const SizedBox(height: 15),

                    // Email button
                    RoundButton(
                      title: "Start with Email",
                      onPressed: () {
                        Get.toNamed('/email_login_screen');
                      },
                      bgcolor: TColor.primary,
                      color1: Colors.white,
                      icon: Icons.email, // Add this for consistency
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
