import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/restaurant_controller.dart';
import 'package:food_delivery_customer/controller/cart_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/controller/wishlist_controller.dart';
import 'package:food_delivery_customer/views/screens/all_menu_items.dart';
import 'package:food_delivery_customer/views/screens/item_detail.dart';
import 'package:get/get.dart';

class MenuItemsWidget extends StatelessWidget {
  const MenuItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final RestaurantController restaurantController =
        Get.find<RestaurantController>();
    final CartController cartController = Get.find<CartController>();
    final UserController userController = Get.find<UserController>();
    final WishlistController wishlistController =
        Get.find<WishlistController>();

    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate card width based on screen size (30-35% of screen width, min 180, max 220)
    final cardWidth = (screenWidth * 0.32).clamp(180.0, 220.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Popular Menu Items',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TColor.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => AllMenuItemsPage());
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (restaurantController.isLoadingMenuItems.value) {
            return _buildLoadingWidget();
          }

          if (restaurantController.error.value.isNotEmpty) {
            return _buildErrorWidget(restaurantController.error.value);
          }

          final displayItems = restaurantController.menuItems.take(6).toList();

          if (displayItems.isEmpty) {
            return _buildEmptyWidget();
          }

          return SizedBox(
            height: screenHeight * 0.26,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: displayItems.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                return _buildMenuItemCard(
                  item,
                  cartController,
                  userController,
                  wishlistController,
                  cardWidth,
                  screenHeight * 0.26,
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TColor.primary),
            const SizedBox(height: 16),
            Text(
              'Loading menu items...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Failed to load items',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                error.length > 50 ? '${error.substring(0, 50)}...' : error,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No menu items available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final restaurantController = Get.find<RestaurantController>();
                restaurantController.refreshMenuItems();
              },
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(
    dynamic item,
    CartController cartController,
    UserController userController,
    WishlistController wishlistController,
    double cardWidth,
    double listHeight,
  ) {
    // Helper method to get the image URL safely
    String getImageUrl() {
      // First try the imageUrl getter from your MenuItem model
      if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
        return item.imageUrl!;
      }
      // Then try to get from images array if available
      if (item.images != null &&
          item.images.isNotEmpty &&
          item.images.first.imageUrl.isNotEmpty) {
        return item.images.first.imageUrl;
      }
      // Try direct image field as fallback (if it exists in some responses)
      if (item.image != null && item.image.isNotEmpty) {
        return item.image;
      }
      return '';
    }

    final imageUrl = getImageUrl();

    // Calculate image height as 45% of card height
    final imageHeight = listHeight * 0.45;

    // Calculate content padding based on card size
    final contentPadding = cardWidth * 0.05;

    // Safe getters for text fields
    final String title = item.title?.toString() ?? 'Unknown Item';
    final String description =
        item.description?.toString() ?? 'Delicious food item';
    final String priceText = item.formattedPrice?.toString() ?? '\$0.00';

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: () {
          Get.to(() => MenuItemDetailPage(menuItemId: item.id));
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image - Dynamic height
              Container(
                height: imageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey[200],
                ),
                child: Stack(
                  children: [
                    // Item Image
                    imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: imageHeight,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: TColor.primary,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderIcon(imageHeight);
                              },
                            ),
                          )
                        : _buildPlaceholderIcon(imageHeight),

                    // Wishlist Button on Image
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Obx(() {
                        final isInWishlist =
                            wishlistController.isItemInWishlist(item.id);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isInWishlist
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isInWishlist ? Colors.red : TColor.primary,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: cardWidth * 0.16,
                              minHeight: cardWidth * 0.16,
                            ),
                            onPressed: () {
                              if (userController.isLoggedIn) {
                                wishlistController.toggleWishlist(
                                  menuItem: item,
                                  accessToken: userController.accessToken,
                                );
                              } else {
                                Get.snackbar(
                                  'Login Required',
                                  'Please login to add items to wishlist',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Item Details - Flexible to use remaining space
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(contentPadding.clamp(8.0, 12.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title and Description
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: (cardWidth * 0.07).clamp(13.0, 16.0),
                                fontWeight: FontWeight.bold,
                                color: TColor.primaryText,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: contentPadding * 0.3),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: (cardWidth * 0.055).clamp(10.0, 12.0),
                                color: Colors.grey[600],
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Price and Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              priceText,
                              style: TextStyle(
                                fontSize: (cardWidth * 0.075).clamp(14.0, 16.0),
                                fontWeight: FontWeight.bold,
                                color: TColor.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // In your menu items widget, update the add button:

                          // In the menu items widget, update the add button section
                          Container(
                            decoration: BoxDecoration(
                              color: TColor.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Obx(() {
                              final isProcessing = cartController
                                  .isItemProcessing('${item.id}_add');
                              return IconButton(
                                icon: isProcessing
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  TColor.primary),
                                        ),
                                      )
                                    : Icon(
                                        Icons.add_circle,
                                        color: TColor.primary,
                                        size: (cardWidth * 0.10)
                                            .clamp(18.0, 24.0),
                                      ),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: cardWidth * 0.16,
                                  minHeight: cardWidth * 0.16,
                                ),
                                onPressed: isProcessing
                                    ? null
                                    : () async {
                                        final userController =
                                            Get.find<UserController>();
                                        if (!userController.isLoggedIn) {
                                          Get.snackbar(
                                            'Login Required',
                                            'Please login to add items to cart',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.orange,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        try {
                                          await cartController.addToCart(
                                            menuItem: item,
                                            quantity: 1,
                                            accessToken:
                                                userController.accessToken,
                                          );

                                          // Snackbar shows immediately now
                                        } catch (e) {
                                          Get.snackbar(
                                            'Error',
                                            'Failed to add item to cart: ${e.toString()}',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.grey[300],
      ),
      child: Center(
        child: Icon(
          Icons.fastfood,
          size: height * 0.35,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}
