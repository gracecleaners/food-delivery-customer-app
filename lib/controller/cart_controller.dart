import 'package:food_delivery_customer/models/menu_item.dart';
import 'package:get/get.dart';
import 'package:food_delivery_customer/services/api_service.dart';
import 'package:food_delivery_customer/models/cart.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController {
  final ApiService _apiService = Get.find();

  final Rx<Cart?> _cart = Rx<Cart?>(null);
  final Rx<Cart?> _localCart =
      Rx<Cart?>(null); // Local cart for immediate UI updates
  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs; // Track sync status
  final RxString error = ''.obs;

  Cart? get cart =>
      _localCart.value ?? _cart.value; // Prefer local cart for display
  List<CartItem> get cartItems => cart?.items ?? [];
  int get cartItemCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => cart?.totalPrice ?? 0.0;
  bool get hasItems => cartItems.isNotEmpty;
  final RxMap<String, bool> _itemProcessingStates = <String, bool>{}.obs;

  // Add this to your CartController
  final RxBool isCheckingOut = false.obs;

  // Add this method to handle checkout process
  Future<bool> proceedToCheckout() async {
    try {
      isCheckingOut.value = true;
      error.value = '';

      // Simulate some processing time (you can remove this in production)
      await Future.delayed(const Duration(milliseconds: 500));

      // Your existing checkout logic would go here
      // For now, just return success
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isCheckingOut.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeLocalCart();
  }

  void disposeSnackbars() {
    try {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
    } catch (e) {
      print('Error closing snackbars: $e');
    }
  }

  // Initialize local cart from storage
  void _initializeLocalCart() {
    final localCartData = GetStorage().read('local_cart');
    if (localCartData != null) {
      try {
        _localCart.value = Cart.fromJson(localCartData);
        print('🛒 Local cart loaded: ${_localCart.value?.items.length} items');
      } catch (e) {
        print('❌ Error loading local cart: $e');
        _clearLocalCart();
      }
    }
  }

  // Save local cart to storage
  void _saveLocalCart() {
    if (_localCart.value != null) {
      try {
        GetStorage().write('local_cart', _localCart.value!.toJson());
      } catch (e) {
        print('❌ Error saving local cart: $e');
      }
    } else {
      GetStorage().remove('local_cart');
    }
  }

  // Clear local cart
  void _clearLocalCart() {
    _localCart.value = null;
    GetStorage().remove('local_cart');
  }

  // Create a local cart item
  CartItem _createLocalCartItem({
    required MenuItem menuItem,
    required int quantity,
  }) {
    return CartItem(
      id: 'local_${menuItem.id}_${DateTime.now().millisecondsSinceEpoch}',
      menuItem: menuItem,
      quantity: quantity,
      totalPrice: menuItem.price * quantity,
    );
  }

  // Create a local cart
  Cart _createLocalCart() {
    return Cart(
      id: 'local_cart_${DateTime.now().millisecondsSinceEpoch}',
      items: [],
      totalPrice: 0.0,
      createdAt: DateTime.now(),
    );
  }

  Future<bool> addToCart({
    required MenuItem menuItem,
    required int quantity,
    required String? accessToken,
  }) async {
    final itemKey = '${menuItem.id}_add';

    try {
      _setItemProcessing(itemKey, true);
      isLoading.value = true; // Set loading state
      error.value = '';

      // 1. FIRST: Add to local cart for immediate UI update
      await _addToLocalCart(menuItem: menuItem, quantity: quantity);

      // 2. Add a small delay to ensure smooth UI transition (2 seconds as requested)
      // await Future.delayed(const Duration(seconds: 2));

      // 3. THEN: Sync with backend in background if we have access token
      if (accessToken != null && accessToken.isNotEmpty) {
        _syncWithBackend(accessToken: accessToken);
      }
      Get.snackbar('Cart', '$menuItem successfully added to cart');
     
      return true;
    } catch (e) {
      error.value = e.toString();
      // If local add failed, revert any changes
      _revertLocalChanges();
      return false;
    } finally {
      _setItemProcessing(itemKey, false);
      isLoading.value = false; // Clear loading state
    }
  }

  // Add item to local cart (immediate)
  Future<void> _addToLocalCart({
    required MenuItem menuItem,
    required int quantity,
  }) async {
    // Create or get local cart
    if (_localCart.value == null) {
      _localCart.value = _createLocalCart();
    }

    final existingItemIndex = _localCart.value!.items
        .indexWhere((item) => item.menuItem.id == menuItem.id);

    if (existingItemIndex != -1) {
      // Update existing item
      final existingItem = _localCart.value!.items[existingItemIndex];
      final newQuantity = existingItem.quantity + quantity;
      final newTotalPrice = menuItem.price * newQuantity;

      _localCart.value!.items[existingItemIndex] = CartItem(
        id: existingItem.id,
        menuItem: menuItem,
        quantity: newQuantity,
        totalPrice: newTotalPrice,
      );
    } else {
      // Add new item
      final newItem = _createLocalCartItem(
        menuItem: menuItem,
        quantity: quantity,
      );
      _localCart.value!.items.add(newItem);
    }

    // Recalculate total
    _recalculateLocalCartTotal();

    // Save to local storage
    _saveLocalCart();

    // Force UI update
    _localCart.refresh();

    print(
        '🛒 Local cart updated: ${_localCart.value!.items.length} items, Total: \$${_localCart.value!.totalPrice}');
  }

  // Recalculate local cart total
  void _recalculateLocalCartTotal() {
    if (_localCart.value != null) {
      final total = _localCart.value!.items
          .fold(0.0, (sum, item) => sum + item.totalPrice);
      _localCart.value = _localCart.value!.copyWith(totalPrice: total);
    }
  }

  // Sync local cart with backend
  Future<void> _syncWithBackend({required String accessToken}) async {
    if (_localCart.value == null || _localCart.value!.items.isEmpty) return;

    try {
      isSyncing.value = true;
      print('🔄 Syncing local cart with backend...');

      // Get or create remote cart
      String cartId;
      if (_cart.value == null) {
        final cartResponse = await _apiService.post('orders/carts/', {});
        cartId = cartResponse['id'];
        await GetStorage().write('current_cart_id', cartId);
        _cart.value = Cart.fromJson(cartResponse);
      } else {
        cartId = _cart.value!.id;
      }

      // Sync each item with backend
      for (final localItem in _localCart.value!.items) {
        if (localItem.id.startsWith('local_')) {
          // This is a local item that needs to be synced
          try {
            final response = await _apiService.post(
              'orders/carts/$cartId/items/',
              {
                'menu_item_id': localItem.menuItem.id,
                'qty': localItem.quantity,
              },
            );

            print('✅ Synced item: ${localItem.menuItem.title}');
          } catch (e) {
            print(
                '❌ Failed to sync item: ${localItem.menuItem.title}, Error: $e');
            // Continue with other items even if one fails
          }
        }
      }

      // Refresh remote cart to get updated data
      await getCart();

      // Merge local cart with remote cart
      await _mergeCarts();

      print('✅ Cart sync completed');
    } catch (e) {
      print('❌ Cart sync failed: $e');
      // Don't show error to user - local cart will continue to work
    } finally {
      isSyncing.value = false;
    }
  }

  // Merge local and remote carts
  Future<void> _mergeCarts() async {
    if (_cart.value == null || _localCart.value == null) return;

    // For now, just replace local cart with remote cart after sync
    // You can implement more sophisticated merging logic here
    _localCart.value = _cart.value;
    _saveLocalCart();
  }

  // Revert local changes in case of error
  void _revertLocalChanges() {
    _initializeLocalCart(); // Reload from storage
  }

  // FAST LOCAL QUANTITY UPDATE
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
    required String? accessToken, // Changed to nullable
  }) async {
    final itemKey = '${itemId}_update';

    try {
      _setItemProcessing(itemKey, true);

      // 1. FIRST: Update locally
      await _updateLocalQuantity(itemId: itemId, quantity: quantity);

      // 2. THEN: Sync with backend if we have access token
      if (accessToken != null && accessToken.isNotEmpty) {
        _syncQuantityWithBackend(
            itemId: itemId, quantity: quantity, accessToken: accessToken);
      }
    } catch (e) {
      error.value = e.toString();
      _revertLocalChanges();
      rethrow;
    } finally {
      _setItemProcessing(itemKey, false);
    }
  }

  // Update quantity locally
  Future<void> _updateLocalQuantity({
    required String itemId,
    required int quantity,
  }) async {
    if (_localCart.value == null) return;

    final itemIndex =
        _localCart.value!.items.indexWhere((item) => item.id == itemId);

    if (itemIndex != -1) {
      if (quantity <= 0) {
        // Remove item
        _localCart.value!.items.removeAt(itemIndex);
      } else {
        // Update quantity
        final item = _localCart.value!.items[itemIndex];
        _localCart.value!.items[itemIndex] = CartItem(
          id: item.id,
          menuItem: item.menuItem,
          quantity: quantity,
          totalPrice: item.menuItem.price * quantity,
        );
      }

      _recalculateLocalCartTotal();
      _saveLocalCart();
      _localCart.refresh();
    }
  }

  // Sync quantity with backend
  Future<void> _syncQuantityWithBackend({
    required String itemId,
    required int quantity,
    required String accessToken,
  }) async {
    if (!itemId.startsWith('local_')) {
      // This is already a remote item, update directly
      try {
        final cartId = GetStorage().read('current_cart_id');
        if (cartId == null) return;

        if (quantity <= 0) {
          await _apiService.delete('orders/carts/$cartId/items/$itemId/');
        } else {
          await _apiService.patch(
            'orders/carts/$cartId/items/$itemId/',
            {'qty': quantity},
          );
        }

        await getCart(); // Refresh remote cart
        await _mergeCarts(); // Update local cart with remote data
      } catch (e) {
        print('❌ Failed to sync quantity: $e');
      }
    }
    // For local items, they will be synced in the next full sync
  }

  // FAST LOCAL REMOVE FROM CART
  Future<void> removeFromCart({
    required String itemId,
    required String? accessToken, // Changed to nullable
  }) async {
    final itemKey = '${itemId}_remove';

    try {
      _setItemProcessing(itemKey, true);

      // 1. FIRST: Remove locally
      await _removeFromLocalCart(itemId: itemId);

      // 2. THEN: Sync with backend if we have access token
      if (accessToken != null && accessToken.isNotEmpty) {
        _syncRemoveWithBackend(itemId: itemId, accessToken: accessToken);
      }

      Get.snackbar(
        'Removed',
        'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      error.value = e.toString();
      _revertLocalChanges();
      rethrow;
    } finally {
      _setItemProcessing(itemKey, false);
    }
  }

  // Remove item locally
  Future<void> _removeFromLocalCart({required String itemId}) async {
    if (_localCart.value == null) return;

    _localCart.value!.items.removeWhere((item) => item.id == itemId);
    _recalculateLocalCartTotal();
    _saveLocalCart();
    _localCart.refresh();
  }

  // Sync remove with backend
  Future<void> _syncRemoveWithBackend({
    required String itemId,
    required String accessToken,
  }) async {
    if (!itemId.startsWith('local_')) {
      // This is a remote item, remove directly
      try {
        final cartId = GetStorage().read('current_cart_id');
        if (cartId == null) return;

        await _apiService.delete('orders/carts/$cartId/items/$itemId/');
        await getCart(); // Refresh remote cart
        await _mergeCarts(); // Update local cart with remote data
      } catch (e) {
        print('❌ Failed to sync remove: $e');
      }
    }
    // For local items, they will be synced in the next full sync
  }

  // Existing methods with local-first approach
  Future<void> initializeCart({required String? accessToken}) async {
    // Changed to nullable
    try {
      // Only try to get existing cart from backend if we have access token
      if (accessToken != null && accessToken.isNotEmpty) {
        await getCart();

        // If we have a remote cart, use it as the source of truth
        if (_cart.value != null) {
          _localCart.value = _cart.value;
          _saveLocalCart();
        }
      }
    } catch (e) {
      print('Error initializing cart: $e');
      // Continue with local cart if backend fails
    }
  }

  Future<void> getCart() async {
    try {
      final cartId = GetStorage().read('current_cart_id');

      if (cartId != null) {
        final response = await _apiService.get('orders/carts/$cartId/');
        _cart.value = Cart.fromJson(response);
      }
    } catch (e) {
      print('Error getting cart: $e');
      // Don't throw error - we'll use local cart
    }
  }

  Future<void> clearCart({required String? accessToken}) async {
    // Changed to nullable
    try {
      // Clear both local and remote
      _clearLocalCart();

      // Only clear remote cart if we have access token
      if (accessToken != null && accessToken.isNotEmpty) {
        final cartId = GetStorage().read('current_cart_id');
        if (cartId != null) {
          await _apiService.delete('orders/carts/$cartId/');
        }
      }

      _cart.value = null;
      await GetStorage().remove('current_cart_id');

      Get.snackbar('Cleared', 'Cart cleared');
    } catch (e) {
      error.value = e.toString();
      // Even if remote clear fails, local cart is cleared
      rethrow;
    }
  }

  // Rest of your existing methods...
  bool isItemProcessing(String itemId) {
    return _itemProcessingStates[itemId] ?? false;
  }

  void _setItemProcessing(String itemId, bool processing) {
    _itemProcessingStates[itemId] = processing;
  }

  void clearCartLocally() {
    _localCart.value = null;
    _cart.value = null;
    _clearLocalCart();
    print('🛒 Cart cleared locally');
  }

  bool get isLoadingValue => isLoading.value;
  bool get isSyncingValue => isSyncing.value;
}
