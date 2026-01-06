// utils/snackbar_utils.dart - UPDATED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtils {
  static bool _isSnackbarShown = false;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void showSnackbar(String title, String message, {bool isError = false}) {
    // Prevent multiple snackbars
    if (_isSnackbarShown) {
      Get.closeCurrentSnackbar();
    }
    
    _isSnackbarShown = true;
    
    // Use a delayed approach to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isError ? Colors.red : Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutBack,
          snackbarStatus: (status) {
            if (status == SnackbarStatus.CLOSED || status == SnackbarStatus.CLOSING) {
              _isSnackbarShown = false;
            }
          },
        );
      } catch (e) {
        print('⚠️ Snackbar error: $e - Falling back to simple snackbar');
        _showSimpleSnackbar(title, message, isError: isError);
        _isSnackbarShown = false;
      }
    });
  }

  static void _showSimpleSnackbar(String title, String message, {bool isError = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final context = navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              backgroundColor: isError ? Colors.red : Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        print('⚠️ Simple snackbar also failed: $e');
      }
    });
  }

  // For success messages
  static void showSuccess(String message) {
    showSnackbar('Success', message, isError: false);
  }

  // For error messages
  static void showError(String message) {
    showSnackbar('Error', message, isError: true);
  }

  // For info messages
  static void showInfo(String message) {
    showSnackbar('Info', message, isError: false);
  }
}