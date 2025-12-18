import 'package:flutter/material.dart';
import 'package:food_delivery_customer/controller/cart_controller.dart';
import 'package:food_delivery_customer/models/location.dart';
import 'package:food_delivery_customer/services/order_storage.dart';
import 'package:get/get.dart';
import 'package:food_delivery_customer/services/api_service.dart';
import 'package:food_delivery_customer/models/cart.dart';
import 'package:food_delivery_customer/controller/location_controller.dart';
import 'package:get_storage/get_storage.dart';

class OrderController extends GetxController {
  final ApiService _apiService = Get.find();
  final LocationController _locationController = Get.find<LocationController>();
  final OrderStorageService _storageService = OrderStorageService();

  final RxList<Order> _orders = <Order>[].obs;
  final RxList<Order> _localOrders =
      <Order>[].obs; // Local orders for immediate UI
  final Rx<Order?> _selectedOrder = Rx<Order?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isSyncing = false.obs; // Track sync status
  final RxString error = ''.obs;

  List<Order> get orders =>
      _localOrders.isNotEmpty ? _localOrders.toList() : _orders.toList();
  Order? get selectedOrder => _selectedOrder.value;
  int get orderCount => orders.length;

  // Filter orders by status (uses local data first)
  List<Order> get pendingOrders =>
      orders.where((order) => order.status.toLowerCase() == 'pending').toList();
  List<Order> get activeOrders => orders
      .where((order) => ['accepted', 'preparing', 'ready', 'out_for_delivery']
          .contains(order.status.toLowerCase()))
      .toList();
  List<Order> get completedOrders => orders
      .where((order) =>
          ['delivered', 'completed'].contains(order.status.toLowerCase()))
      .toList();
  List<Order> get cancelledOrders => orders
      .where((order) => order.status.toLowerCase() == 'cancelled')
      .toList();

  @override
  void onInit() {
    super.onInit();
    _initializeLocalOrders();
  }

  // Initialize local orders from storage
  void _initializeLocalOrders() {
    final localOrdersData = GetStorage().read('local_orders');
    if (localOrdersData != null && localOrdersData is List) {
      try {
        _localOrders.clear();
        for (final orderData in localOrdersData) {
          try {
            final order = Order.fromJson(Map<String, dynamic>.from(orderData));
            _localOrders.add(order);
          } catch (e) {
            print('❌ Error parsing local order: $e');
          }
        }
        _localOrders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
        print('📦 Local orders loaded: ${_localOrders.length} items');
      } catch (e) {
        print('❌ Error loading local orders: $e');
        _clearLocalOrders();
      }
    }
  }


// Clear all notifications (mark orders as seen)
Future<void> clearNotifications() async {
  try {
    print('🔔 Clearing order notifications...');
    
    // Get orders that currently have notifications
    final ordersToClear = orders.where((order) {
      final status = order.status.toLowerCase();
      return status == 'placed' || 
             status == 'pending' || 
             status == 'accepted' || 
             status == 'preparing' || 
             status == 'ready' || 
             status == 'out_for_delivery';
    }).toList();
    
    print('🔔 Orders to clear notifications: ${ordersToClear.length}');
    
    // Store the cleared order IDs in local storage
    final clearedOrders = GetStorage().read('cleared_order_notifications') ?? [];
    final List<dynamic> updatedClearedOrders = List.from(clearedOrders);
    
    for (final order in ordersToClear) {
      if (!updatedClearedOrders.contains(order.id)) {
        updatedClearedOrders.add(order.id);
        print('🔔 Marked order ${order.id} as seen');
      }
    }
    
    await GetStorage().write('cleared_order_notifications', updatedClearedOrders);
    
    print('🔔 Notifications cleared. Updated count: ${getNotificationCount()}');
    
    // Update the UI
    update();
    
  } catch (e) {
    print('❌ Error clearing notifications: $e');
  }
}

// Get notification count EXCLUDING cleared orders
int getNotificationCount() {
  final clearedOrders = GetStorage().read('cleared_order_notifications') ?? [];
  
  return orders.where((order) {
    final status = order.status.toLowerCase();
    final shouldNotify = status == 'placed' || 
                         status == 'pending' || 
                         status == 'accepted' || 
                         status == 'preparing' || 
                         status == 'ready' || 
                         status == 'out_for_delivery';
    
    // Only notify if order should be notified AND hasn't been cleared
    return shouldNotify && !clearedOrders.contains(order.id);
  }).length;
}

// Clear specific order notification
void clearOrderNotification(int orderId) {
  final clearedOrders = GetStorage().read('cleared_order_notifications') ?? [];
  final List<dynamic> updatedClearedOrders = List.from(clearedOrders);
  
  if (!updatedClearedOrders.contains(orderId)) {
    updatedClearedOrders.add(orderId);
    GetStorage().write('cleared_order_notifications', updatedClearedOrders);
    print('🔔 Cleared notification for order $orderId');
    update();
  }
}

// Check if an order has been seen/cleared
bool isOrderSeen(int orderId) {
  final clearedOrders = GetStorage().read('cleared_order_notifications') ?? [];
  return clearedOrders.contains(orderId);
}

// Clear all cleared notifications (reset)
void resetAllNotifications() {
  GetStorage().remove('cleared_order_notifications');
  print('🔔 All notifications reset');
  update();
}

// Replace the existing notificationCount getter with:
int get notificationCount {
  return getNotificationCount(); // Use the new method
}

// Keep the existing Rx getter for reactivity:
RxInt get notificationCountRx {
  return notificationCount.obs;
}


// Get notification count for specific order types
Map<String, int> get notificationBreakdown {
  return {
    'pending': pendingOrders.length,
    'active': activeOrders.length,
    'total': notificationCount,
  };
}

  // Save local orders to storage
  void _saveLocalOrders() {
    try {
      final ordersJson = _localOrders.map((order) => order.toJson()).toList();
      GetStorage().write('local_orders', ordersJson);
    } catch (e) {
      print('❌ Error saving local orders: $e');
    }
  }

  // Clear local orders
  void _clearLocalOrders() {
    _localOrders.clear();
    GetStorage().remove('local_orders');
  }

  // Add order to local storage immediately
  void _addToLocalOrders(Order order) {
    _localOrders.insert(0, order);
    _localOrders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    _saveLocalOrders();
    print('📦 Order added to local storage: ${order.id}');
  }

  // Update order in local storage
  void _updateLocalOrder(Order updatedOrder) {
    final index =
        _localOrders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _localOrders[index] = updatedOrder;
      _saveLocalOrders();
      print('📦 Order updated in local storage: ${updatedOrder.id}');
    }
  }

 
Future<Order?> createOrderFromCart({
  required String cartId,
  required String deliveryAddress,
  DeliveryLocation? deliveryLocation,
  String? specialInstructions,
  String? paymentMethod = 'cash',
}) async {
  try {
    isLoading.value = true;
    error.value = '';

    print('📦 Creating order with delivery location:');
    print('📦   Address: $deliveryAddress');
    if (deliveryLocation != null) {
      print('📦   Coordinates: ${deliveryLocation.latitude}, ${deliveryLocation.longitude}');
    }

    // 1. FIRST: Create a local order immediately for UI feedback
    final localOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary local ID
      status: 'pending',
      paymentStatus: 'pending', // ADD THIS REQUIRED PARAMETER
      items: [],
      totalAmount: 0.0, // Will be updated from backend
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      placedAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 30)),
      dropoffLocation: deliveryLocation != null ? {
        'latitude': deliveryLocation.latitude,
        'longitude': deliveryLocation.longitude,
        'address': deliveryLocation.address ?? deliveryAddress,
        if (deliveryLocation.placeName != null) 'place_name': deliveryLocation.placeName,
      } : null,
      specialInstructions: specialInstructions,
    );

    _addToLocalOrders(localOrder);
    
    // 2. THEN: Create order in backend and sync
    final orderData = {
      'cart_id': cartId,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      if (deliveryLocation != null) ...{
        'dropoff_location': {
          'latitude': deliveryLocation.latitude,
          'longitude': deliveryLocation.longitude,
          'address': deliveryLocation.address ?? deliveryAddress,
          if (deliveryLocation.placeName != null) 'place_name': deliveryLocation.placeName,
        },
      },
      if (specialInstructions != null && specialInstructions.isNotEmpty)
        'special_instructions': specialInstructions,
    };

    print('📦 Order data: $orderData');

    final response = await _apiService.post('orders/orders/', orderData);
    final backendOrder = Order.fromJson(response);
    
    // Store the dropoff location locally
    if (deliveryLocation != null) {
      final locationData = {
        'latitude': deliveryLocation.latitude,
        'longitude': deliveryLocation.longitude,
        'address': deliveryLocation.address ?? deliveryAddress,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _storageService.saveOrderLocation(backendOrder.id, locationData);
    }

    // Replace local order with backend order
    _localOrders.removeWhere((order) => order.id == localOrder.id);
    _addToLocalOrders(backendOrder);
    _orders.insert(0, backendOrder);
    
    print('🛒 Order created successfully: ${backendOrder.id}');

    // Clear cart
    final cartController = Get.find<CartController>();
    cartController.clearCartLocally();
    await GetStorage().remove('current_cart_id');

    Get.snackbar(
      'Order Placed!',
      'Your order #${backendOrder.id} has been placed successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );

    // Sync orders in background to get latest status
    _syncOrdersInBackground();

    return backendOrder;
  } catch (e) {
    error.value = e.toString();
    print('❌ Error placing order: $e');
    
    // Remove local order if backend creation failed
    _localOrders.removeWhere((order) => order.id == DateTime.now().millisecondsSinceEpoch);
    
    Get.snackbar(
      'Order Failed',
      'Failed to place order: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    rethrow;
  } finally {
    isLoading.value = false;
  }
}

  // FAST LOCAL ORDERS LOADING - Show local data immediately, sync in background
  Future<void> getUserOrders({String? accessToken}) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Show local orders immediately if available
      if (_localOrders.isNotEmpty) {
        print('📦 Showing ${_localOrders.length} local orders immediately');
        // Local orders are already available through the getter
      }

      // Sync with backend in background
      _syncOrdersInBackground(accessToken: accessToken);
    } catch (e) {
      error.value = e.toString();
      print('❌ Error in getUserOrders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sync orders with backend (background process)
  Future<void> _syncOrdersInBackground({String? accessToken}) async {
    try {
      isSyncing.value = true;
      print('🔄 Syncing orders with backend...');

      final response = await _apiService.get('orders/orders/');

      print('📦 Backend orders response: $response');

      List<dynamic> ordersList = [];

      // Handle different response formats
      if (response is List) {
        ordersList = response;
        print(
            '📦 Backend response is direct List with ${ordersList.length} items');
      } else if (response is Map && response.containsKey('data')) {
        ordersList = response['data'] ?? [];
        print(
            '📦 Backend response has data field with ${ordersList.length} items');
      } else if (response is Map && response.containsKey('results')) {
        ordersList = response['results'] ?? [];
        print(
            '📦 Backend response has results field with ${ordersList.length} items');
      } else {
        print('📦 Unexpected backend response format: ${response.runtimeType}');
      }

      if (ordersList.isNotEmpty) {
        print('📦 Parsing ${ordersList.length} backend orders...');
        final parsedOrders = <Order>[];

        for (final orderData in ordersList) {
          try {
            print('📦 Processing backend order data: $orderData');
            var order = Order.fromJson(orderData);
            // Enhance order with local storage data
            order = await _enhanceOrderWithLocalData(order);
            parsedOrders.add(order);
            print('✅ Successfully parsed backend order: ${order.id}');
          } catch (e) {
            print('❌ Error parsing backend order: $e');
            print('❌ Problematic backend order data: $orderData');
          }
        }

        // Update backend orders
        _orders.assignAll(parsedOrders);
        _orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));

        // Merge with local orders (backend data takes precedence)
        _mergeLocalWithBackendOrders(parsedOrders);

        print('📦 Successfully synced ${_orders.length} orders from backend');
      } else {
        _orders.clear();
        print('📦 No orders found in backend response');
      }
    } catch (e) {
      print('❌ Error syncing orders with backend: $e');
      // Don't show error to user - local orders will continue to work
    } finally {
      isSyncing.value = false;
    }
  }

  // Merge local orders with backend orders
  void _mergeLocalWithBackendOrders(List<Order> backendOrders) {
    final backendOrderIds = backendOrders.map((order) => order.id).toSet();

    // Remove local orders that don't exist in backend (they were likely temporary)
    _localOrders.removeWhere((localOrder) =>
        localOrder.id is int &&
        localOrder.id < 1000000000000 && // Remove temporary local IDs
        !backendOrderIds.contains(localOrder.id));

    // Add backend orders to local storage
    for (final backendOrder in backendOrders) {
      final existingIndex =
          _localOrders.indexWhere((order) => order.id == backendOrder.id);
      if (existingIndex != -1) {
        // Update existing order with backend data
        _localOrders[existingIndex] = backendOrder;
      } else {
        // Add new backend order
        _localOrders.add(backendOrder);
      }
    }

    // Sort and save
    _localOrders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    _saveLocalOrders();

    print(
        '📦 Merged ${backendOrders.length} backend orders with local storage');
  }

  // Update the Order model to include local storage lookup
  Future<Order> _enhanceOrderWithLocalData(Order order) async {
    final localLocation = _storageService.getOrderLocation(order.id);
    if (localLocation != null && order.dropoffLocation == null) {
      return order.copyWith(
        dropoffLocation: localLocation,
        deliveryAddress: localLocation['address'] ?? order.deliveryAddress,
      );
    }
    return order;
  }

  // FAST LOCAL ORDER DETAIL - Try local first, then backend
  Future<void> getOrderDetail(int orderId, {String? accessToken}) async {
    try {
      isLoadingDetail.value = true;
      error.value = '';

      // 1. FIRST: Try to get from local orders
      final localOrder =
          _localOrders.firstWhereOrNull((order) => order.id == orderId);
      if (localOrder != null) {
        _selectedOrder.value = localOrder;
        print('📦 Order detail loaded from local storage: $orderId');
      }

      // 2. THEN: Try to get from backend for latest data
      try {
        final response = await _apiService.get('orders/$orderId/');
        final backendOrder = Order.fromJson(response);
        _selectedOrder.value = backendOrder;

        // Update local storage with latest data
        _updateLocalOrder(backendOrder);

        print('📦 Order detail updated from backend: $orderId');
      } catch (e) {
        print('⚠️ Could not fetch order detail from backend: $e');
        // Continue with local data if backend fails
      }
    } catch (e) {
      error.value = e.toString();
      print('Error fetching order detail: $e');
      rethrow;
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Validate order can be placed
  Future<bool> validateOrderPlacement() async {
    final deliveryLocation = _locationController.selectedLocation;

    if (deliveryLocation == null) {
      Get.snackbar(
        'Location Required',
        'Please set your delivery location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Check if address is valid
    if (deliveryLocation.address == null ||
        deliveryLocation.address!.isEmpty ||
        deliveryLocation.address!.contains('Unknown')) {
      final shouldContinue = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Confirm Location'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'We couldn\'t get a detailed address for your location.'),
                  const SizedBox(height: 12),
                  Text(
                      'Coordinates: ${deliveryLocation.latitude.toStringAsFixed(6)}, ${deliveryLocation.longitude.toStringAsFixed(6)}'),
                  const SizedBox(height: 12),
                  const Text('Do you want to continue with these coordinates?'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ) ??
          false;

      if (!shouldContinue) {
        return false;
      }
    }

    return true;
  }

  // FAST LOCAL ORDER TRACKING
  Future<void> trackOrder(int orderId, {String? accessToken}) async {
    try {
      await getOrderDetail(orderId, accessToken: accessToken);
    } catch (e) {
      error.value = e.toString();
      rethrow;
    }
  }

  Future<void> rateOrder(
    int orderId, {
    required double rating,
    String? review,
    int? deliveryRating,
    String? accessToken,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final ratingData = {
        'order_id': orderId,
        'rating': rating,
        if (review != null && review.isNotEmpty) 'review': review,
        if (deliveryRating != null) 'delivery_rating': deliveryRating,
      };

      await _apiService.post('orders/$orderId/rate/', ratingData);

      // Update local order with rating
      final localOrder =
          _localOrders.firstWhereOrNull((order) => order.id == orderId);
      if (localOrder != null) {
        // final updatedOrder = localOrder.copyWith(
        //   rating: rating,
        //   review: review,
        // );
        final updatedOrder = localOrder.copyWith();
        _updateLocalOrder(updatedOrder);
      }

      Get.snackbar(
        'Success',
        'Thank you for your rating!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to submit rating: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> reorder(int orderId, {String? accessToken}) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _apiService.post('orders/$orderId/reorder/', {});

      Get.snackbar(
        'Success',
        'Items added to cart successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to reorder: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh orders with background sync
  Future<void> refreshOrders({String? accessToken}) async {
    await _syncOrdersInBackground(accessToken: accessToken);
  }

  void clearSelectedOrder() {
    _selectedOrder.value = null;
  }

  Order? getOrderById(int orderId) {
    return orders.firstWhereOrNull((order) => order.id == orderId);
  }

  List<Order> getOrdersByStatus(String status) {
    return orders
        .where((order) => order.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  List<Order> get recentOrders {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return orders
        .where((order) => order.placedAt.isAfter(thirtyDaysAgo))
        .toList();
  }

  double get totalSpent {
    return orders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  bool get hasOrders => orders.isNotEmpty;
  bool get isLoadingValue => isLoading.value;
  bool get isLoadingDetailValue => isLoadingDetail.value;
  bool get isSyncingValue => isSyncing.value;

  // Clear all orders (useful for logout)
  void clearOrders() {
    _orders.clear();
    _localOrders.clear();
    _clearLocalOrders();
    _selectedOrder.value = null;
    print('📦 All orders cleared');
  }

  // Initialize orders services
  Future<void> initializeOrders({String? accessToken}) async {
    try {
      // Load local orders immediately
      _initializeLocalOrders();

      // Sync with backend in background if we have access token
      if (accessToken != null && accessToken.isNotEmpty) {
        _syncOrdersInBackground(accessToken: accessToken);
      }
    } catch (e) {
      print('Error initializing orders: $e');
      // Continue with local orders if backend fails
    }
  }
}
