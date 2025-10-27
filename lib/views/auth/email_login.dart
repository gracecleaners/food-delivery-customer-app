import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/email_auth_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:get/get.dart';

class EmailLoginScreen extends StatelessWidget {
  const EmailLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmailAuthController());
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
                  SizedBox(height: media.width * 0.8),
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
                              color: TColor.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Enter your email to get started with verification code!",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ),
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
                                child: Icon(
                                  Icons.email_outlined,
                                  color: TColor.primary,
                                ),
                              ),
                              const VerticalDivider(
                                  width: 1, color: Colors.grey),
                              Expanded(
                                child: TextField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 12),
                                    hintText: "Enter email address",
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
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Obx(() => TextButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.requestOtp,
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          TColor.primary),
                                    ),
                                  )
                                : Text(
                                    "Get Code",
                                    style: TextStyle(color: TColor.primary),
                                  ),
                          )),
                    ),
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
                          "Or",
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.7)),
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
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        "Back to Login",
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
