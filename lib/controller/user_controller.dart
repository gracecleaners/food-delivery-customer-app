import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_customer/controller/cart_controller.dart';
import 'package:food_delivery_customer/controller/restaurant_controller.dart';
import 'package:food_delivery_customer/controller/wishlist_controller.dart';
import 'package:food_delivery_customer/models/user.dart';
import 'package:food_delivery_customer/services/google.dart';
import 'package:get/get.dart';
import 'package:food_delivery_customer/services/api_service.dart';
import 'package:food_delivery_customer/services/token_service.dart';

class UserController extends GetxController {
  final ApiService _apiService = Get.find();
  final TokenService _tokenService = Get.find<TokenService>();
  final GoogleSignInService _googleSignInService = Get.find<GoogleSignInService>();

  // Reactive user object
  final Rx<User?> _user = Rx<User?>(null);
  Rx<User?> get userObs => _user;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshingToken = false.obs;
  final RxString error = ''.obs;

  // Reactive access token
  final RxString _accessToken = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeToken();
    checkAuthStatus();
  }

  // Getters
  User? get user => _user.value;
  bool get isLoggedIn => _accessToken.value.isNotEmpty; 
  String? get accessToken => _accessToken.value.isEmpty ? null : _accessToken.value;

  // Initialize token from storage
  Future<void> _initializeToken() async {
    try {
      final token = await _tokenService.getAccessToken();
      _accessToken.value = token ?? '';
      print('🔐 Token initialized: ${_accessToken.value.isNotEmpty ? "present" : "empty"}');
    } catch (e) {
      print('❌ Error initializing token: $e');
      _accessToken.value = '';
    }
  }

  // Update token when it changes
  Future<void> _updateToken(String? token) async {
    _accessToken.value = token ?? '';
    print('🔐 Token updated: ${_accessToken.value.isNotEmpty ? "present" : "empty"}');
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      error.value = '';

      print('🔐 Starting Google authentication process...');

      Map<String, dynamic>? googleAuthData;
      int retryCount = 0;
      const maxRetries = 2;

      while (retryCount < maxRetries) {
        try {
          googleAuthData = await _googleSignInService.signIn();
          if (googleAuthData != null) break;
          
          retryCount++;
          if (retryCount < maxRetries) {
            print('🔄 Retrying Google Sign-In (attempt ${retryCount + 1}/$maxRetries)...');
            await Future.delayed(const Duration(seconds: 1));
          }
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) rethrow;
          print('🔄 Retrying after error (attempt ${retryCount + 1}/$maxRetries)...');
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      if (googleAuthData == null) {
        throw Exception('Google Sign-In was cancelled or failed after $maxRetries attempts');
      }

      print('✅ Google authentication successful, sending to backend...');

      final response = await _apiService.postPublic(
        'users/auth/google/', 
        googleAuthData
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Server connection timed out. Please try again.');
      });

      print('✅ Backend Google authentication response received');

      await _handleGoogleAuthResponse(response, googleAuthData);

    } on TimeoutException catch (e) {
      error.value = 'Connection timeout. Please check your internet and try again.';
      print('❌ Google Sign-In timeout: $e');
    } on SocketException catch (e) {
      error.value = 'Network error. Please check your internet connection.';
      print('❌ Google Sign-In network error: $e');
    } on PlatformException catch (e) {
      error.value = _getGoogleSignInError(e);
      print('❌ Google Sign-In PlatformException: $e');
    } catch (e) {
      error.value = _getGoogleSignInError(e);
      print('❌ Google Sign-In error: $e');
    } finally {
      isLoading.value = false;
      
      if (error.value.isNotEmpty) {
        Get.snackbar(
          'Google Sign-In Failed',
          error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> response) async {
    try {
      print('🔐 Handling authentication response...');
      
      Map<String, dynamic> tokens = {};
      
      if (response.containsKey('tokens') && response['tokens'] is Map) {
        tokens = Map<String, dynamic>.from(response['tokens']);
      } else if (response.containsKey('access') || response.containsKey('access_token')) {
        tokens = {
          'access': response['access'] ?? response['access_token'],
          'refresh': response['refresh'] ?? response['refresh_token'],
        };
      } else if (response is Map<String, dynamic>) {
        tokens = Map<String, dynamic>.from(response);
      }

      if (tokens['access'] == null) {
        throw Exception('No access token received from server');
      }

      await _tokenService.saveTokens(tokens);
      await _initializeToken();
      print('✅ Tokens saved successfully');

      if (response.containsKey('user')) {
        final userData = response['user'];
        final user = User.fromJson(userData);
        await _tokenService.saveUserData(user);
        _user.value = user;
        print('✅ User data saved: ${user.email}');
      } else if (response.containsKey('email')) {
        final user = User.fromJson(response);
        await _tokenService.saveUserData(user);
        _user.value = user;
        print('✅ User data created from response: ${user.email}');
      }

    } catch (e) {
      print('❌ Error handling auth response: $e');
      rethrow;
    }
  }

  Future<void> _handleGoogleAuthResponse(Map<String, dynamic> response, Map<String, dynamic> googleAuthData) async {
    try {
      print('🔄 Processing Google auth response...');

      bool hasTokens = response.containsKey('tokens') || 
                      response.containsKey('access') || 
                      response.containsKey('access_token');
      
      bool hasUser = response.containsKey('user');
      
      print('🔍 Response analysis - hasTokens: $hasTokens, hasUser: $hasUser');

      if (hasTokens && hasUser) {
        print('✅ Existing user authenticated successfully');
        
        await _handleAuthResponse(response);
        await getProfile();
        
        // Initialize restaurant controller with user ID
        await _initializeUserServices();
        
        Get.offAllNamed('/home');
        
      } else if (response['user_exists'] == false || response['requires_registration'] == true) {
        print('🆕 New Google user detected, requesting phone number');
        Get.toNamed('/google_phone_input', arguments: googleAuthData);
        
      } else if (response.containsKey('detail') || response.containsKey('error')) {
        final errorMessage = response['detail'] ?? response['error'] ?? response['message'] ?? 'Authentication failed';
        throw Exception(errorMessage);
        
      } else if (response.containsKey('id') || response.containsKey('email')) {
        print('✅ User object received directly');
        
        final formattedResponse = {
          'user': response,
          'tokens': {
            'access': response['access_token'] ?? response['access'],
            'refresh': response['refresh_token'] ?? response['refresh'],
          }
        };
        
        await _handleAuthResponse(formattedResponse);
        await getProfile();
        
        await _initializeUserServices();
        Get.offAllNamed('/home');
        
      } else {
        print('❌ Unexpected response format: ${response.keys}');
        throw Exception('Unexpected response from server. Please try again.');
      }
      
    } catch (e) {
      print('❌ Error handling Google auth response: $e');
      rethrow;
    }
  }

  Future<void> registerUserWithGoogle(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;
      error.value = '';

      print('📝 Google Registration data: ${userData.keys}');
      
      final response = await _apiService.postPublic('users/auth/google/register/', userData);

      print('✅ Google Registration response received');

      if (response.containsKey('tokens') || response.containsKey('access')) {
        await _tokenService.saveTokens(response.containsKey('tokens') ? response['tokens'] : response);
        await _initializeToken();
        
        if (response.containsKey('user')) {
          _user.value = User.fromJson(response['user']);
        } else {
          _user.value = User.fromJson({
            'id': response['id'],
            'email': userData['email'],
            'first_name': userData['first_name'],
            'last_name': userData['last_name'],
            'phone': userData['phone'],
            'user_type': 'customer',
            'is_verified': true,
            'username': userData['email'].split('@').first,
          });
        }
        
        await _tokenService.saveUserData(_user.value!);

        print('✅ Google Registration successful');
        
        await _initializeUserServices();
        Get.offAllNamed('/home');
        
      } else if (response.containsKey('id') || response.containsKey('email')) {
        print('✅ Direct user object received');
        
        await _tokenService.saveTokens({
          'access': response['access_token'] ?? response['access'],
          'refresh': response['refresh_token'] ?? response['refresh'],
        });
        await _initializeToken();
        
        _user.value = User.fromJson(response);
        await _tokenService.saveUserData(_user.value!);
        
        await _initializeUserServices();
        Get.offAllNamed('/home');
        
      } else {
        print('❌ Unexpected registration response format');
        throw Exception('Registration completed but unexpected response format');
      }
      
    } catch (e) {
      error.value = e.toString();
      print('❌ Google Registration error: $e');
      
      Get.snackbar(
        'Registration Failed',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAuthStateFromStorage() async {
    await _initializeToken(); 
    final cachedUser = await _tokenService.getUserData();
    if (cachedUser != null) _user.value = cachedUser;
    print('🔄 Auth state refreshed from storage: isLoggedIn=$isLoggedIn');
  }

  Future<void> registerUser(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;
      error.value = '';

      print('📝 Registration data: $userData');
      final response = await _apiService.post('users/auth/register/', userData);

      print('✅ Registration response: $response');
      
      await _tokenService.saveTokens(response['tokens']);
      await _initializeToken();
      
      _user.value = User.fromJson(response['user']);
      await _tokenService.saveUserData(_user.value!);

      print('✅ Registration successful');
      
      await _initializeUserServices();
      
      Get.offAllNamed('/home');
    } catch (e) {
      error.value = e.toString();
      print('❌ Registration error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _apiService.post('auth/verify-otp/', {
        'email': email,
        'otp': otp,
      });

      if (response['user_exists'] == true) {
        await _tokenService.saveTokens(response['tokens']);
        await _initializeToken();
        
        _user.value = User.fromJson(response['user']);
        await _tokenService.saveUserData(_user.value!);
        
        print('✅ OTP verification successful');
        
        await _initializeUserServices();
        
        Get.offAllNamed('/home');
      } else {
        Get.toNamed('/register', arguments: {'email': email});
      }
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _apiService.post('users/auth/login/', {
        'email': email,
        'password': password,
      });

      await _tokenService.saveTokens(response);
      await _initializeToken();
      await getProfile();

      print('✅ Login successful');
      
      await _initializeUserServices();
      
      Get.offAllNamed('/home');
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  String _getGoogleSignInError(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('network_error') ||
        errorString.contains('NetworkError') ||
        errorString.contains('SocketException') ||
        errorString.contains('ApiException: 7')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (errorString.contains('TimeoutException')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (errorString.contains('sign_in_failed') || 
               errorString.contains('SIGN_IN_FAILED')) {
      return 'Google Sign-In failed. Please try again.';
    } else if (errorString.contains('cancelled') || 
               errorString.contains('canceled')) {
      return 'Sign-In was cancelled.';
    } else if (errorString.contains('INVALID_ACCOUNT')) {
      return 'Invalid Google account. Please try with a different account.';
    } else if (errorString.contains('invalid') || 
               errorString.contains('Invalid')) {
      return 'Authentication failed. Please try again.';
    } else if (errorString.contains('500') || 
               errorString.contains('internal_error')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('400') || 
               errorString.contains('bad_request')) {
      return 'Authentication failed. Please try again.';
    } else {
      return 'Google Sign-In failed. Please try again.';
    }
  }

  Map<String, dynamic> _extractTokens(Map<String, dynamic> response) {
    final tokens = <String, dynamic>{};

    if (response.containsKey('access')) {
      tokens['access'] = response['access'];
    } else if (response.containsKey('access_token')) {
      tokens['access'] = response['access_token'];
    } else if (response.containsKey('token')) {
      tokens['access'] = response['token'];
    }

    if (response.containsKey('refresh')) {
      tokens['refresh'] = response['refresh'];
    } else if (response.containsKey('refresh_token')) {
      tokens['refresh'] = response['refresh_token'];
    }

    if (response.containsKey('expires_in')) {
      tokens['expires_in'] = response['expires_in'];
    } else if (response.containsKey('expiry')) {
      tokens['expiry'] = response['expiry'];
    }

    print('🔑 Extracted tokens - Access: ${tokens['access'] != null ? "present" : "null"}');
    
    return tokens;
  }

  // Enhanced service initialization with RestaurantController integration
  Future<void> _initializeUserServices() async {
    try {
      if (!isLoggedIn) {
        print('❌ Cannot initialize services: User not logged in');
        return;
      }
      
      final token = accessToken;
      if (token == null || token.isEmpty) {
        print('❌ Cannot initialize services: No access token');
        return;
      }

      final userId = _user.value?.id?.toString() ?? '';
      if (userId.isEmpty) {
        print('⚠️ No user ID available for restaurant controller');
      }

      print('🔄 Initializing all user services...');
      
      // Initialize RestaurantController with user login
      final restaurantController = Get.find<RestaurantController>();
      if (userId.isNotEmpty) {
        await restaurantController.onUserLogin(userId);
      }
      
      // Initialize Cart
      final cartController = Get.find<CartController>();
      print('🛒 Initializing cart...');
      await cartController.initializeCart(accessToken: token);
      
      // Initialize Wishlist
      final wishlistController = Get.find<WishlistController>();
      print('❤️ Initializing wishlist...');
      await wishlistController.loadWishlist(token);
      
      print('✅ All user services initialized successfully');
    } catch (e) {
      print('⚠️ Error initializing user services: $e');
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      await _initializeToken();
      
      if (isLoggedIn) {
        print('✅ User has token, checking if expired...');
        
        final isExpired = await _tokenService.isAccessTokenExpired();
        if (isExpired) {
          print('🔄 Token expired, attempting refresh...');
          final refreshed = await refreshAuthToken();
          if (!refreshed) {
            print('❌ Token refresh failed');
          } else {
            print('✅ Token refreshed successfully');
          }
        }
        
        final cachedUser = _tokenService.getUserData();
        if (cachedUser != null) {
          _user.value = cachedUser;
          print('✅ User loaded from cache: ${_user.value?.email}');
        }
        
        try {
          await getProfile();
          print('✅ Profile loaded successfully from API');
        } catch (e) {
          print('⚠️ API profile load failed: $e');
          if (_user.value == null && cachedUser == null) {
            print('❌ No user data available, logging out');
            await logout();
            return;
          }
          print('🔄 Continuing with cached user data');
        }
      } else {
        print('❌ No valid token found');
      }
    } catch (e) {
      print('❌ Auth status check error: $e');
    }
  }

  Future<bool> refreshAuthToken() async {
    try {
      isRefreshingToken.value = true;
      final success = await _apiService.refreshToken();
      if (success) {
        await _initializeToken();
        print('✅ Token refreshed successfully');
        return true;
      } else {
        print('❌ Token refresh failed');
        return false;
      }
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    } finally {
      isRefreshingToken.value = false;
    }
  }

  Future<void> getProfile({bool fromCache = false}) async {
    try {
      if (fromCache) {
        final cachedUser = _tokenService.getUserData();
        if (cachedUser != null) {
          _user.value = cachedUser;
          return;
        }
      }
      
      if (!isLoggedIn) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.get('users/auth/profile/');
      _user.value = User.fromJson(response);
      await _tokenService.saveUserData(_user.value!);
      
      print('✅ Profile loaded successfully: ${_user.value?.email}');
    } catch (e) {
      print('❌ Get profile error: $e');
      
      if (e.toString().contains('401') || 
          e.toString().contains('403') || 
          e.toString().contains('Session expired') || 
          e.toString().contains('Not authenticated')) {
        
        print('🔄 Auth error detected, attempting token refresh...');
        final refreshed = await refreshAuthToken();
        
        if (refreshed) {
          try {
            final response = await _apiService.get('users/auth/profile/');
            _user.value = User.fromJson(response);
            await _tokenService.saveUserData(_user.value!);
            print('✅ Profile loaded after token refresh: ${_user.value?.email}');
            return;
          } catch (retryError) {
            print('❌ Profile retry failed: $retryError');
          }
        }
      }
      
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      // Clear restaurant controller data
      final restaurantController = Get.find<RestaurantController>();
      await restaurantController.onUserLogout();
      
      await _googleSignInService.signOut();
      
      if (_accessToken.value.isNotEmpty) {
        final refreshToken = await _tokenService.getRefreshToken();
        if (refreshToken != null) {
          await _apiService.post('users/auth/logout/', {
            'refresh_token': refreshToken,
          }).timeout(const Duration(seconds: 5), onTimeout: () {
            print('⚠️ Logout API timeout - continuing with local logout');
            return {};
          });
        }
      }
    } catch (e) {
      print('⚠️ Logout API error (non-critical): $e');
    } finally {
      await _tokenService.clearTokens();
      _user.value = null;
      _accessToken.value = '';
      error.value = '';
      isLoading.value = false;
      
      print('✅ User logged out successfully');
      Get.offAllNamed('/login');
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _apiService.put('users/auth/profile/', updates);
      _user.value = User.fromJson(response);
      await _tokenService.saveUserData(_user.value!);
      
      print('✅ Profile updated successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      print('❌ Update profile error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkGoogleAuthStatus() async {
    try {
      return await _googleSignInService.isSignedIn();
    } catch (e) {
      print('❌ Google auth status check error: $e');
      return false;
    }
  }

  Future<void> createUserFromOtpResponse(Map<String, dynamic> userData) async {
    try {
      _user.value = User.fromJson(userData);
      await _tokenService.saveUserData(_user.value!);
      print('✅ User created from OTP response: ${_user.value?.email}');
    } catch (e) {
      print('❌ Error creating user from OTP response: $e');
      throw Exception('Failed to create user from OTP response');
    }
  }

  void clearUser() async {
    // Clear restaurant controller data
    final restaurantController = Get.find<RestaurantController>();
    await restaurantController.onUserLogout();
    
    _user.value = null;
    _accessToken.value = '';
    _tokenService.clearTokens();
    error.value = '';
  }

  Future<bool> needsReauthentication() async {
    if (!isLoggedIn) return true;
    
    final isExpired = await _tokenService.isAccessTokenExpired();
    return isExpired;
  }

  Future<String?> getAccessTokenAsync() async {
    return await _tokenService.getAccessToken();
  }

  Future<void> forceTokenCheck() async {
    print('🔄 Force checking token state...');
    await _initializeToken();
    print('🔄 Token check complete - isLoggedIn: $isLoggedIn');
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('internet')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('cancelled') || errorString.contains('canceled')) {
      return 'Google Sign-In was cancelled.';
    } else if (errorString.contains('sign_in_failed')) {
      return 'Google Sign-In failed. Please try again.';
    } else if (errorString.contains('invalid') || errorString.contains('token')) {
      return 'Authentication failed. Please try again.';
    } else if (errorString.contains('account_not_found')) {
      return 'No account found with this Google account. Please try signing up first.';
    } else {
      return 'An error occurred during Google Sign-In. Please try again.';
    }
  }
}