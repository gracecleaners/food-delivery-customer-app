import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/cart_controller.dart';
import 'package:food_delivery_customer/controller/location_controller.dart';
import 'package:food_delivery_customer/controller/order_controller.dart'; // Add this
import 'package:food_delivery_customer/controller/restaurant_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/controller/wishlist_controller.dart';
import 'package:food_delivery_customer/views/screens/Home_view/featured.dart';
import 'package:food_delivery_customer/views/screens/favorite.dart';
import 'package:food_delivery_customer/views/screens/home_view/categories.dart';
import 'package:food_delivery_customer/views/screens/home_view/popular_restaurants.dart';
import 'package:food_delivery_customer/views/screens/home_view/promo.dart';
import 'package:food_delivery_customer/views/screens/cart.dart';
import 'package:food_delivery_customer/views/screens/get_started.dart';
import 'package:food_delivery_customer/views/screens/location_selection.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;
  final UserController _userController = Get.find<UserController>();
  final CartController _cartController = Get.find<CartController>();
  final OrderController _orderController =
      Get.find<OrderController>(); // Add this
  final LocationController locationController = Get.find<LocationController>();
  final RestaurantController restaurantController =
      Get.find<RestaurantController>();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    // Initialize user-dependent services when home page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserServices();
    });
  }

  void _initializeUserServices() async {
    final userController = Get.find<UserController>();
    final cartController = Get.find<CartController>();
    final wishlistController = Get.find<WishlistController>();

    // Wait a bit longer to ensure UserController is fully initialized
    await Future.delayed(const Duration(milliseconds: 300));

    if (userController.isLoggedIn && userController.user != null) {
      print('✅ User is logged in: ${userController.user?.email}');

      final accessToken = userController.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          print('🛒 Initializing cart...');
          await cartController.initializeCart(accessToken: accessToken);

          print('📦 Initializing orders...');
          await _orderController.initializeOrders(accessToken: accessToken);

          print('❤️ Initializing wishlist...');
          await wishlistController.loadWishlist(accessToken);

          // Load featured items with promotions (background loading)
          print('🔥 Loading featured items with promotions...');
          await restaurantController.getFeaturedItemsWithPromotions(
              showLoading: false);

          print('✅ User services initialized successfully');
        } catch (e) {
          print('⚠️ Error initializing user services: $e');
        }
      } else {
        print('❌ No access token available for service initialization');
      }
    } else {
      print(
          '❌ User not logged in or user data missing, skipping service initialization');

      // Debug information
      if (userController.user != null && !userController.isLoggedIn) {
        print('🔍 DEBUG: User data exists but isLoggedIn is false');
        print('🔍 This indicates a token initialization issue');
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _unfocusSearch() {
    _focusNode.unfocus();
    _controller.clear();
  }

  Widget _buildLocationHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() {
          final user = _userController.user;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (user != null) ...[
                Text(
                  'Hi, ${user.displayName}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColor.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Orders Icon with Notification Badge
              _buildOrdersNotificationBadge(),
            ],
          );
        }),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () async {
            final selectedLocation =
                await Get.to(() => const LocationSelectionScreen());
            if (selectedLocation != null) {
              locationController.updateSelectedLocation(selectedLocation);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(() {
                    final hasLocation =
                        locationController.selectedLocation != null;
                    final isGettingLocation =
                        locationController.isGettingLocationValue;

                    if (isGettingLocation) {
                      return SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TColor.primary,
                        ),
                      );
                    }

                    return Icon(
                      Icons.location_on,
                      color: hasLocation ? TColor.primary : Colors.grey,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final location = locationController.selectedLocation;
                    final isGettingLocation =
                        locationController.isGettingLocationValue;

                    if (isGettingLocation) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Getting your location...",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Please wait",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: TColor.primaryText,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location == locationController.currentLocation
                              ? "Your current location"
                              : "Delivery location",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          location?.address ?? "Tap to set delivery location",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: location != null
                                ? TColor.primaryText
                                : Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final isGettingLocation =
                      locationController.isGettingLocationValue;
                  return isGettingLocation
                      ? const SizedBox(width: 16, height: 16)
                      : Icon(Icons.arrow_forward_ios,
                          color: TColor.primary, size: 16);
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersNotificationBadge() {
    return GestureDetector(
      onTap: () {
        print('📱 Orders icon tapped - navigating to OrdersPage');
        Get.to(() => OrdersPage());
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long,
              color: TColor.primaryText,
              size: 24,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Obx(() {
              final notificationCount = _orderController.notificationCount;

              print('🎯 Orders badge - Count: $notificationCount');

              if (notificationCount == 0) {
                return const SizedBox();
              }

              return Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  notificationCount > 9 ? '9+' : notificationCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear restaurant data and reset loading state
              await restaurantController.onUserLogout();

              // Clear user data
              _userController.clearUser();

              // Navigate to get started screen
              Get.to(() => const GetStarted());

              // Show success message
              Get.snackbar(
                'Success',
                'Logged out successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Obx(() {
          // Show full-screen loading ONLY on initial load (first launch or fresh login)
          if (restaurantController.isInitialLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: TColor.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your food experience...',
                    style: TextStyle(
                      fontSize: 16,
                      color: TColor.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          // Normal content - background syncing happens without blocking UI
          return RefreshIndicator(
            onRefresh: () async {
              // Pull to refresh - background sync without loading indicator
              await Future.wait([
                restaurantController.refreshRestaurants(),
                restaurantController.refreshMenuItems(),
                restaurantController.getFeaturedItemsWithPromotions(
                    showLoading: false),
              ]);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: media.height * 0.03),

                  // Location and Profile with enhanced styling
                  _buildLocationHeader(),

                  const SizedBox(height: 28),

                  const SizedBox(height: 24),

                  // Categories Widget
                  const CategoriesWidget(),

                  const SizedBox(height: 32),

                  // Dynamic Promo Banner Widget
                  // No longer shows loading here - uses cached data
                  PromoBannerWidget(
                    featuredItemsWithPromotions:
                        restaurantController.featuredItemsWithPromotions,
                    onBannerTap: () {
                      print('🏷️ Promo banner tapped');
                      // Handle banner tap if needed
                    },
                  ),

                  const SizedBox(height: 32),

                  // Popular Restaurants Widget
                  PopularRestaurantsWidget(),

                  const SizedBox(height: 32),

                  // Featured Menu Items
                  const MenuItemsWidget(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
