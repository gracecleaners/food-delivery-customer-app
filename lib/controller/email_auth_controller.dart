import 'package:flutter/material.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/models/auth_verification.dart';
import 'package:food_delivery_customer/services/auth_service.dart';
import 'package:food_delivery_customer/utils/api_endpoint.dart';
import 'package:food_delivery_customer/views/screens/Home_view/homescreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EmailAuthController extends GetxController {
  final _authService = AuthService();
  final UserController _userController = Get.find<UserController>();

  final isLoading = false.obs;
  final isResending = false.obs;
  final emailController = TextEditingController();
  final List<TextEditingController> otpController =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNode = List.generate(6, (_) => FocusNode());

  @override
  void onClose() {
    emailController.dispose();
    for (var controller in otpController) {
      controller.dispose();
    }
    for (var node in focusNode) {
      node.dispose();
    }
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter email";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  String getOtpCode() {
    return otpController.map((c) => c.text).join();
  }

  bool isOtpComplete() {
    return getOtpCode().length == 6;
  }

  void clearOtp() {
    for (var controller in otpController) {
      controller.clear();
    }
  }

  Future<void> requestOtp() async {
  final email = emailController.text.trim();
  final error = validateEmail(email);

  if (error != null) {
    Get.snackbar('Error', error,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white);
    return; // IMPORTANT: Return here to stop execution
  }
  
  isLoading.value = true;

  try {
    final response = await _authService.requestOtpEmail(email);
    Get.snackbar('Success', response.message,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green);
    Get.toNamed('/email_verification_screen', arguments: email);
  } on ApiException catch (e) {
    Get.snackbar(
      'Error',
      e.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    print('API Exception: ${e.message}');
  } catch (e) {
    Get.snackbar(
      'Error',
      'Failed to send OTP: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    print('Unexpected error: $e');
  } finally {
    isLoading.value = false;
  }
}

  Future<void> verifyOtp(String email) async {
    if (!isOtpComplete()) {
      Get.snackbar(
        'Error',
        'Please enter complete verification code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _authService.verifyOtpEmail(email, getOtpCode());

      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Save user data and tokens
      _userController.setUser(
        response.user,
        response.accessToken,
        response.refreshToken,
      );

      // Navigate to home
      Get.offAllNamed('/home');
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Unexpected Error',
        'Please try again: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp(String email) async {
    isResending.value = true;

    try {
      final response = await _authService.requestOtpEmail(email);

      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearOtp();
      focusNode[0].requestFocus();
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isResending.value = false;
    }
  }
}
