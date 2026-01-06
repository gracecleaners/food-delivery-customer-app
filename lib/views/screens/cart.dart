import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/cart_controller.dart';
import 'package:food_delivery_customer/controller/location_controller.dart';
import 'package:food_delivery_customer/controller/order_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/models/cart.dart';
import 'package:food_delivery_customer/utils/context_snackbar.dart';
import 'package:food_delivery_customer/views/screens/all_menu_items.dart';
import 'package:food_delivery_customer/views/screens/location_selection.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController _cartController = Get.find<CartController>();
  final UserController _userController = Get.find<UserController>();
  final LocationController _locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_userController.isLoggedIn && _cartController.cart == null) {
        _cartController.initializeCart(
            accessToken: _userController.accessToken);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 20),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    'My Cart',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    if (_cartController.hasItems) {
                      return TextButton(
                        onPressed: () => _showClearCartDialog(),
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                ],
              ),
            ),

            // Cart Content
            Obx(() {
              if (_cartController.isLoading.value) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (!_cartController.hasItems) {
                return _buildEmptyCart();
              }

              return _buildCartItems(media);
            }),

            // Order Summary
            Obx(() {
              if (!_cartController.hasItems) return const SizedBox();

              return _buildOrderSummary();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    var media = MediaQuery.of(context).size;

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: TColor.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'No items in cart',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your favorite foods are waiting!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: media.width * 0.6,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.to(AllMenuItemsPage());
                },
                child: const Text(
                  'Browse Menu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(Size media) {
    return Expanded(
      child: Obx(() {
        if (_cartController.cart == null) {
          return _buildEmptyCart();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _cartController.cart!.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = _cartController.cart!.items[index];
            return _buildCartItemCard(item, media);
          },
        );
      }),
    );
  }

  Widget _buildCartItemCard(CartItem item, Size media) {
    return Obx(() {
      final isProcessing =
          _cartController.isItemProcessing('${item.id}_update') ||
              _cartController.isItemProcessing('${item.id}_remove');

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Food Image - FIXED: Use menuItem.imageUrl directly
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: _getItemImage(item),
              ),
              child: item.menuItem.imageUrl == null ||
                      item.menuItem.imageUrl!.isEmpty
                  ? Icon(Icons.fastfood, color: Colors.grey[400])
                  : null,
            ),
            const SizedBox(width: 16),

            // Food Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menuItem.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.menuItem.restaurantName ?? 'Restaurant',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColor.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: TColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 18, color: TColor.primary),
                    onPressed: isProcessing
                        ? null
                        : () {
                            _cartController.updateQuantity(
                              itemId: item.id,
                              quantity: item.quantity - 1,
                              accessToken: _userController.accessToken,
                            );
                          },
                  ),
                  Text(
                    item.quantity.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 18, color: TColor.primary),
                    onPressed: isProcessing
                        ? null
                        : () {
                            _cartController.updateQuantity(
                              itemId: item.id,
                              quantity: item.quantity + 1,
                              accessToken: _userController.accessToken,
                            );
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // FIXED: Helper method to get item image that works for both local and synced items
  DecorationImage? _getItemImage(CartItem item) {
    if (item.menuItem.imageUrl != null && item.menuItem.imageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(item.menuItem.imageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildOrderSummary() {
    final CartController cartController = Get.find<CartController>();
    final UserController userController = Get.find<UserController>();
    final LocationController locationController =
        Get.find<LocationController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Delivery Location Button
          _buildDeliveryLocationButton(),
          const SizedBox(height: 16),

          _buildSummaryRow(
              'Subtotal', '\$${_cartController.cartTotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Total',
            '\$${_cartController.cartTotal.toStringAsFixed(2)}',
            isTotal: true,
          ),

          const SizedBox(height: 20),

          // Checkout Button with Loading State
          Obx(() {
            final isLoggedIn = userController.isLoggedIn;
            final hasItems = _cartController.hasItems;
            final isCheckingOut = cartController.isCheckingOut.value;
            final hasLocation = locationController.selectedLocation != null;

            // Determine button state and text
            String buttonText;
            bool isEnabled = false;

            if (!isLoggedIn) {
              buttonText = 'Login to Checkout';
            } else if (!hasItems) {
              buttonText = 'Cart is Empty';
            } else if (!hasLocation) {
              buttonText = 'Select Delivery Location';
            } else {
              buttonText =
                  isCheckingOut ? 'Processing...' : 'Proceed to Checkout';
              isEnabled = !isCheckingOut;
            }

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isEnabled ? TColor.primary : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isEnabled ? 2 : 0,
                ),
                onPressed: isEnabled ? () => _proceedToCheckout() : null,
                child: isCheckingOut
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // NEW: Delivery Location Button
  Widget _buildDeliveryLocationButton() {
    return GestureDetector(
      onTap: () async {
        final selectedLocation =
            await Get.to(() => const LocationSelectionScreen());
        if (selectedLocation != null) {
          _locationController.updateSelectedLocation(selectedLocation);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
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
                    _locationController.selectedLocation != null;
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
                final location = _locationController.selectedLocation;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery location",
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
                        color:
                            location != null ? TColor.primaryText : Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: TColor.primary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? TColor.primaryText : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? TColor.primary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to clear all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _cartController.clearCart(
                  accessToken: _userController.accessToken);
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }



  Future<void> _proceedToCheckout() async {
    final cartController = Get.find<CartController>();
    final locationController = Get.find<LocationController>();
    final orderController = Get.find<OrderController>();
    final userController = Get.find<UserController>();

    try {
      // Start loading
      cartController.isCheckingOut.value = true;

      // Check if delivery location is selected
      if (locationController.selectedLocation == null) {
        ContextSnackbar.showWarning(
            context, 'Please select a delivery location');

        // Navigate to location selection
        final selectedLocation =
            await Get.to(() => const LocationSelectionScreen());
        if (selectedLocation == null) {
          cartController.isCheckingOut.value = false;
          return; // User cancelled location selection
        }
        locationController.updateSelectedLocation(selectedLocation);
      }

      // Validate cart
      if (cartController.cart == null) {
        ContextSnackbar.showError(context, 'Cart is empty');
        cartController.isCheckingOut.value = false;
        return;
      }

      final cartId = GetStorage().read('current_cart_id');
      if (cartId == null) {
        ContextSnackbar.showError(context, 'No cart found');
        cartController.isCheckingOut.value = false;
        return;
      }

      // Create order
      final order = await orderController.createOrderFromCart(
        cartId: cartId,
        deliveryAddress:
            locationController.selectedLocation!.address ?? 'Selected location',
        deliveryLocation: locationController.selectedLocation!,
        paymentMethod: 'cash',
      );

      if (order != null) {
        Get.offAll(() => OrderConfirmationPage(order: order));
      }
    } catch (e) {
      ContextSnackbar.showError(context, 'Checkout Failed: ${e.toString()}');
    } finally {
      // Ensure loading state is cleared
      cartController.isCheckingOut.value = false;
    }
  }
}

// Simple order confirmation page
class OrderConfirmationPage extends StatelessWidget {
  final Order order;

  const OrderConfirmationPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: TColor.primary,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Order #${order.id}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your order has been placed successfully!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/home');
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
