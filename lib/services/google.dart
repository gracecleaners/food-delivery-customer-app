import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService extends GetxService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '55727848133-6tp3tfrqc9bkjski9mk0v6309egomf6o.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>?> signIn() async {
    try {
      debugPrint('🔐 Starting Google Sign-In...');
      
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      
      // Attempt sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ User cancelled Google Sign-In');
        return null;
      }

      debugPrint('✅ Google user obtained: ${googleUser.email}');

      // Get authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Validate tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      // Extract name
      final nameParts = (googleUser.displayName ?? '').split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      return {
        'access_token': googleAuth.accessToken!,
        'id_token': googleAuth.idToken!,
        'email': googleUser.email,
        'first_name': firstName,
        'last_name': lastName,
        'user_type': 'customer',
        'photo_url': googleUser.photoUrl,
      };

    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      
      if (e.toString().contains('ApiException: 10')) {
        throw Exception('Google Sign-In setup error. Please contact support.');
      }
      
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ Google Sign-Out successful');
    } catch (e) {
      debugPrint('⚠️ Google Sign-Out error: $e');
    }
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}