import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/order_controller.dart';
import 'package:food_delivery_customer/models/order.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/views/screens/order_detail_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  final OrderController orderController = Get.find<OrderController>();
  final UserController userController = Get.find<UserController>();
  
  late TabController _tabController;
  final List<String> _tabTitles = ['Active', 'Completed', 'Cancelled'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.isLoggedIn) {
        orderController.fetchOrders(accessToken: userController.accessToken);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // App Bar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'My Orders',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          if (userController.isLoggedIn) {
                            orderController.fetchOrders(
                              accessToken: userController.accessToken,
                              forceRefresh: true,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Tabs
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: TColor.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Order Count
          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              final totalOrders = orderController.orders.length;
              final activeOrders = orderController.orders
                  .where((order) => !['delivered', 'cancelled', 'refunded'].contains(order.status))
                  .length;
              
              return Row(
                children: [
                  _buildOrderCountCard(
                    count: totalOrders,
                    label: 'Total Orders',
                    icon: Icons.shopping_bag_outlined,
                    color: TColor.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildOrderCountCard(
                    count: activeOrders,
                    label: 'Active Orders',
                    icon: Icons.access_time,
                    color: Colors.orange,
                  ),
                ],
              );
            }),
          ),
          
          // Orders List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Orders Tab
                _buildOrderList(filter: (order) {
                  return !['delivered', 'cancelled', 'refunded'].contains(order.status);
                }),
                
                // Completed Orders Tab
                _buildOrderList(filter: (order) {
                  return order.status == 'delivered';
                }),
                
                // Cancelled Orders Tab
                _buildOrderList(filter: (order) {
                  return order.status == 'cancelled' || order.status == 'refunded';
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderCountCard({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderList({required bool Function(Order) filter}) {
    return RefreshIndicator(
      onRefresh: () async {
        if (userController.isLoggedIn) {
          await orderController.fetchOrders(
            accessToken: userController.accessToken,
            forceRefresh: true,
          );
        }
      },
      child: Obx(() {
        if (!userController.isLoggedIn) {
          return _buildLoginRequired();
        }
        
        if (orderController.isLoading.value) {
          return _buildLoadingState();
        }
        
        if (orderController.error.isNotEmpty) {
          return _buildErrorState(orderController.error.value);
        }
        
        final filteredOrders = orderController.orders.where(filter).toList();
        
        if (filteredOrders.isEmpty) {
          return _buildEmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'No Orders Found',
            subtitle: _getEmptyStateMessage(_tabController.index),
          );
        }
        
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: filteredOrders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildOrderCard(filteredOrders[index]);
          },
        );
      }),
    );
  }
  
  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        Get.to(() => OrderDetailPage(orderId: order.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Restaurant Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.restaurantName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Order #${order.orderNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Order Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatStatus(order.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            
            // Order Items Preview
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items
                  _buildOrderItemsPreview(order),
                  
                  const SizedBox(height: 12),
                  
                  // Order Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(order.createdAt),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons (for active orders)
            if (!['delivered', 'cancelled', 'refunded'].contains(order.status))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Track order
                          Get.to(() => OrderDetailPage(orderId: order.id));
                        },
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: const Text('Track Order'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: TColor.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (order.status == 'pending' || order.status == 'confirmed')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showCancelOrderDialog(order);
                          },
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderItemsPreview(Order order) {
    final items = order.items.take(2).toList();
    final remainingItems = order.items.length - 2;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: TColor.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  '${item.quantity}x ${item.menuItem.title}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        )),
        
        if (remainingItems > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ $remainingItems more items',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
  
  void _showCancelOrderDialog(Order order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await orderController.cancelOrder(
                  orderId: order.id,
                  accessToken: userController.accessToken,
                );
                Get.snackbar(
                  'Success',
                  'Order has been cancelled',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to cancel order: ${e.toString()}',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
  
  // Helper Methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'on_the_way':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _formatStatus(String status) {
    return status.split('_').map((word) {
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }
  
  String _getEmptyStateMessage(int tabIndex) {
    switch (tabIndex) {
      case 0: // Active
        return 'You have no active orders. Start ordering now!';
      case 1: // Completed
        return 'No completed orders yet';
      case 2: // Cancelled
        return 'No cancelled orders';
      default:
        return 'No orders found';
    }
  }
  
  // Loading, Error, and Empty States
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.grey[200],
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 20,
                    color: Colors.grey[200],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 80,
                color: Colors.grey[100],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildErrorState(String error) {
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
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              if (userController.isLoggedIn) {
                orderController.fetchOrders(accessToken: userController.accessToken);
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (_tabController.index == 0) // Only show on Active tab
            ElevatedButton.icon(
              onPressed: () {
                Get.until((route) => route.isFirst); // Go to home
              },
              icon: const Icon(Icons.restaurant),
              label: const Text('Browse Restaurants'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'Login Required',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Please login to view your orders',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Navigate to login page
              Get.toNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
}