import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/models/menu_item.dart';
import 'package:get/get.dart';
// Use an alias to resolve the import conflict
import 'package:food_delivery_customer/controller/menu_controller.dart'
    as custom_menu;
import 'package:food_delivery_customer/controller/cart_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/controller/wishlist_controller.dart';
import 'package:intl/intl.dart';

class MenuItemDetailPage extends StatefulWidget {
  final int menuItemId;

  const MenuItemDetailPage({super.key, required this.menuItemId});

  @override
  State<MenuItemDetailPage> createState() => _MenuItemDetailPageState();
}

class _MenuItemDetailPageState extends State<MenuItemDetailPage> {
  final custom_menu.MenuItemController menuController =
      Get.find<custom_menu.MenuItemController>();
  final CartController cartController = Get.find<CartController>();
  final UserController userController = Get.find<UserController>();
  final WishlistController wishlistController = Get.find<WishlistController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      menuController.getMenuItemDetail(widget.menuItemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (menuController.isLoadingDetail.value) {
          return _buildLoadingState();
        }

        final menuItem = menuController.selectedMenuItem.value;
        if (menuItem == null) {
          return _buildErrorState('Menu item not found');
        }

        return CustomScrollView(
          slivers: [
            // App Bar with Menu Item Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.white,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: TColor.primary),
                  onPressed: () => Get.back(),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Obx(() {
                    final isInWishlist =
                        wishlistController.isItemInWishlist(menuItem.id);
                    return IconButton(
                      icon: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? Colors.red : TColor.primary,
                      ),
                      onPressed: () {
                        if (userController.isLoggedIn) {
                          wishlistController.toggleWishlist(
                            menuItem: menuItem,
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
                    );
                  }),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Menu Item Image
                    (menuItem.imageUrl ?? '').isNotEmpty
                        ? Image.network(
                            menuItem.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.fastfood,
                              color: Colors.grey[500],
                              size: 80,
                            ),
                          ),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Promotion Badge
                    if (menuItem.hasActivePromotions)
                      Positioned(
                        top: 60,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${menuItem.activePromotions.first.formattedDiscount} OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Menu Item Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            menuItem.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: TColor.primaryText,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (menuItem.hasActivePromotions) ...[
                              Text(
                                menuItem.formattedDiscountedPrice,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.primary,
                                ),
                              ),
                              Text(
                                menuItem.formattedPrice,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ] else
                              Text(
                                menuItem.formattedPrice,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.primary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Dietary Info
                    if ((menuItem.dietaryInfo ?? '').isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: TColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          menuItem.dietaryInfo!,
                          style: TextStyle(
                            fontSize: 12,
                            color: TColor.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Promotion Information
                    if (menuItem.hasActivePromotions)
                      _buildPromotionInfo(menuItem),

                    const SizedBox(height: 16),

                    // Description
                    if (menuItem.description != null &&
                        menuItem.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColor.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            menuItem.description!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // Item Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Item Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColor.primaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                              'Availability',
                              menuItem.isAvailable
                                  ? 'Available'
                                  : 'Not Available'),
                          if (menuItem.prepTimeMinutes != null)
                            _buildInfoRow('Preparation Time',
                                '${menuItem.prepTimeMinutes} mins'),
                          _buildInfoRow(
                              'Category',
                              menuItem.categoryName ??
                                  'Category ${menuItem.category}'),
                          if (menuItem.allergens?.isNotEmpty ?? false)
                            _buildInfoRow('Allergens', menuItem.allergens!),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: menuItem.isAvailable
                            ? () async {
                                try {
                                  final success =
                                      await cartController.addToCart(
                                    menuItem: menuItem,
                                    quantity: 1,
                                    accessToken: userController.accessToken,
                                    // Remove unitPrice parameter - backend handles discounts
                                  );

                                  if (success) {
                                    String successMessage =
                                        '${menuItem.title} added to cart';
                                    if (menuItem.hasActivePromotions) {
                                      successMessage +=
                                          ' with ${menuItem.activePromotions.first.formattedDiscount} discount!';
                                    }

                                    Get.snackbar(
                                      'Success',
                                      successMessage,
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );

                                    Get.back();
                                  }
                                } catch (e) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to add item to cart: ${e.toString()}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              }
                            : null,
                        child: Obx(() {
                          final buttonText = menuItem.isAvailable
                              ? menuItem.hasActivePromotions
                                  ? 'Add to Cart - ${menuItem.formattedDiscountedPrice}'
                                  : 'Add to Cart - ${menuItem.formattedPrice}'
                              : 'Not Available';

                          return cartController.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  buttonText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPromotionInfo(MenuItem menuItem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColor.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔥 Special Offer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          ...menuItem.activePromotions
              .map((promotion) => Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_offer,
                              color: TColor.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              promotion.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            promotion.formattedDiscount,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: TColor.primary,
                            ),
                          ),
                        ],
                      ),
                      if (promotion.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          promotion.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Valid until: ${DateFormat('MMM dd, yyyy').format(promotion.endDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: TColor.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TColor.primary),
          const SizedBox(height: 16),
          Text(
            'Loading menu item...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              menuController.getMenuItemDetail(widget.menuItemId);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
