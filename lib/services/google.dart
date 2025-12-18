// services/google_signin_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService extends GetxService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '55727848133-6tp3tfrqc9bkjski9mk0v6309egomf6o.apps.googleusercontent.com',
    signInOption: SignInOption.standard,
  );

  final RxBool isSigningIn = false.obs;

  Future<Map<String, dynamic>?> signIn() async {
    try {
      debugPrint('🔐 Starting Google Sign-In...');
      
      // Clear any cached accounts
      await _googleSignIn.signOut();
      await Future.delayed(const Duration(milliseconds: 1000));

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException('Google Sign-In timed out.');
        },
      );
      
      if (googleUser == null) {
        debugPrint('❌ Google Sign-In cancelled by user');
        return null;
      }

      debugPrint('✅ Google user obtained: ${googleUser.email}');

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication.timeout(
        const Duration(seconds: 30),
      );
      
      // Extract name parts
      String firstName = '';
      String lastName = '';
      if (googleUser.displayName != null) {
        final nameParts = googleUser.displayName!.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }

      // Return basic user data without phone
      return {
        'access_token': googleAuth.accessToken,
        'id_token': googleAuth.idToken,
        'email': googleUser.email,
        'first_name': firstName,
        'last_name': lastName,
        'user_type': 'customer',
        'photo_url': googleUser.photoUrl,
        // Phone will be collected separately
      };

    } on TimeoutException catch (e) {
      debugPrint('❌ Google Sign-In timeout: $e');
      throw Exception('Google Sign-In timed out. Please try again.');
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      rethrow;
    }
  }

  // Rest of the class remains the same...
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ Google Sign-Out successful');
    } catch (e) {
      debugPrint('⚠️ Google Sign-Out error (non-critical): $e');
    }
  }

  Future<bool> isSignedIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      return account != null;
    } catch (e) {
      return false;
    }
  }
}