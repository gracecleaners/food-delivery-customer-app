import 'package:get/get.dart';
import 'package:food_delivery_customer/services/api_service.dart';
import 'package:food_delivery_customer/models/order.dart';
import 'package:get_storage/get_storage.dart';

class OrderController extends GetxController {
  final ApiService _apiService = Get.find();
  final GetStorage _storage = GetStorage();
  
  final RxList<Order> orders = <Order>[].obs;
  final Rx<Order?> selectedOrder = Rx<Order?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxString error = ''.obs;
  
  // Cache keys
  static const String _ordersCacheKey = 'cached_orders';
  static const String _lastFetchTimeKey = 'orders_last_fetch';
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  Future<void> fetchOrders({
    required String accessToken,
    bool forceRefresh = false,
  }) async {
    try {
      final now = DateTime.now();
      final lastFetchTime = _storage.read<DateTime>(_lastFetchTimeKey);
      final isCacheValid = lastFetchTime != null && 
                          now.difference(lastFetchTime) < _cacheDuration;
      
      // Return cached data if valid and not forcing refresh
      if (isCacheValid && !forceRefresh) {
        final cachedOrders = _storage.read<List>(_ordersCacheKey);
        if (cachedOrders != null) {
          orders.value = cachedOrders
              .map((order) => Order.fromJson(Map<String, dynamic>.from(order)))
              .toList();
          print('✅ Using cached orders: ${orders.length} orders');
          return;
        }
      }
      
      isLoading.value = true;
      error.value = '';
      
      final response = await _apiService.get('orders/my-orders/');
      if (response is List) {
        orders.value = response
            .map((order) => Order.fromJson(Map<String, dynamic>.from(order)))
            .toList();
        
        // Cache the orders
        await _saveOrdersToCache();
        await _storage.write(_lastFetchTimeKey, now);
        
        print('✅ Fetched ${orders.length} orders');
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ Error fetching orders: $e');
      
      // Fallback to cache
      final cachedOrders = _storage.read<List>(_ordersCacheKey);
      if (cachedOrders != null) {
        orders.value = cachedOrders
            .map((order) => Order.fromJson(Map<String, dynamic>.from(order)))
            .toList();
        print('🔄 API failed, using cached orders');
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> fetchOrderDetail({
    required String orderId,
    required String accessToken,
  }) async {
    try {
      isLoadingDetail.value = true;
      error.value = '';
      
      final response = await _apiService.get('orders/$orderId/');
      if (response != null) {
        selectedOrder.value = Order.fromJson(Map<String, dynamic>.from(response));
      } else {
        throw Exception('Failed to fetch order details');
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ Error fetching order detail: $e');
      rethrow;
    } finally {
      isLoadingDetail.value = false;
    }
  }
  
  Future<void> cancelOrder({
    required String orderId,
    required String accessToken,
  }) async {
    try {
      error.value = '';
      
      await _apiService.post('orders/$orderId/cancel/', {});
      
      // Update local state
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        orders[orderIndex] = orders[orderIndex].copyWith(status: 'cancelled');
      }
      
      if (selectedOrder.value?.id == orderId) {
        selectedOrder.value = selectedOrder.value!.copyWith(status: 'cancelled');
      }
      
      // Update cache
      await _saveOrdersToCache();
      
      print('✅ Order $orderId cancelled');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error cancelling order: $e');
      rethrow;
    }
  }
  
  Future<void> reorder({
    required String orderId,
    required String accessToken,
  }) async {
    try {
      error.value = '';
      
      final response = await _apiService.post('orders/$orderId/reorder/', {});
      
      // Handle reorder response
      if (response['success'] == true) {
        print('✅ Order $orderId reordered');
      } else {
        throw Exception('Reorder failed');
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ Error reordering: $e');
      rethrow;
    }
  }
  
  // Cache management
  Future<void> _saveOrdersToCache() async {
    try {
      final ordersJson = orders.map((order) => order.toJson()).toList();
      await _storage.write(_ordersCacheKey, ordersJson);
    } catch (e) {
      print('❌ Error saving orders to cache: $e');
    }
  }
  
  void clearCache() {
    _storage.remove(_ordersCacheKey);
    _storage.remove(_lastFetchTimeKey);
    orders.clear();
    selectedOrder.value = null;
  }
  
  // Getters
  int get activeOrdersCount => orders
      .where((order) => !['delivered', 'cancelled', 'refunded'].contains(order.status))
      .length;
  
  int get completedOrdersCount => orders
      .where((order) => order.status == 'delivered')
      .length;
  
  double get totalSpent => orders
      .where((order) => order.status == 'delivered')
      .fold(0.0, (sum, order) => sum + order.totalAmount);
  
  // Get order by ID
  Order? getOrderById(String orderId) {
    return orders.firstWhereOrNull((order) => order.id == orderId);
  }
}