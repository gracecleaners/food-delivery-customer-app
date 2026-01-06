// utils/context_snackbar.dart
import 'package:flutter/material.dart';

class ContextSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.green);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.red);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.blue);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.orange);
  }

  static void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}