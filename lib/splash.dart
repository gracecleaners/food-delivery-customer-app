import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/cart_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/controller/wishlist_controller.dart';
import 'package:food_delivery_customer/services/token_service.dart';
import 'package:food_delivery_customer/views/screens/get_started.dart';
import 'package:food_delivery_customer/views/screens/main_tab/main_tab_view.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }


void _initializeApp() async {
  try {
    print('🚀 Initializing app...');
    
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    final userController = Get.find<UserController>();
    
    // Wait for user controller to fully initialize
    await userController.checkAuthStatus();
    
    // Force token check to ensure state is correct
    await userController.forceTokenCheck();
    
    print('🔐 Final auth status check:');
    print('🔐 isLoggedIn: ${userController.isLoggedIn}');
    print('🔐 accessToken: ${userController.accessToken != null ? "present" : "null"}');
    print('🔐 User: ${userController.user != null ? userController.user!.email : "null"}');
    
    if (userController.isLoggedIn && userController.user != null) {
      print('✅ User is logged in: ${userController.user?.email}');
      
      // Initialize user-dependent services
      await _initializeUserServices(userController);
      
      print('✅ All services initialized, navigating to home');
      Get.offAll(() => const MainTabView());
    } else {
      print('❌ No valid session, going to login screen');
      Get.offAll(() => const GetStarted());
    }
  } catch (e) {
    print('❌ Error during app initialization: $e');
    // Fallback navigation
    Get.offAll(() => const GetStarted());
  }
}


Future<void> _initializeUserServices(UserController userController) async {
  try {
    final cartController = Get.find<CartController>();
    final wishlistController = Get.find<WishlistController>();
    
    final accessToken = userController.accessToken;
    
    print('🛒 Initializing cart with token: ${accessToken != null ? "present" : "null"}');
    await cartController.initializeCart(accessToken: accessToken);
    
    print('❤️ Initializing wishlist with token: ${accessToken != null ? "present" : "null"}');
    await wishlistController.loadWishlist(accessToken);
    
    print('✅ All user services initialized successfully');
  } catch (e) {
    print('⚠️ Error initializing user services: $e');
  }
}

  
  Future<bool> _checkTokenValidity(TokenService tokenService) async {
    try {
      final accessToken = await tokenService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found');
        return false;
      }

      // Check if token is expired
      final isExpired = await tokenService.isAccessTokenExpired();
      if (isExpired) {
        print('🔄 Token expired, attempting refresh...');
        final userController = Get.find<UserController>();
        final refreshed = await userController.refreshAuthToken();
        if (!refreshed) {
          print('❌ Token refresh failed');
          await tokenService.clearTokens();
          return false;
        }
        print('✅ Token refreshed successfully');
      }

      return true;
    } catch (e) {
      print('❌ Error checking token validity: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'FUDZ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}