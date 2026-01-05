import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/order_controller.dart';
import 'package:food_delivery_customer/models/order.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderController orderController = Get.find<OrderController>();
  final UserController userController = Get.find<UserController>();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.isLoggedIn) {
        orderController.fetchOrderDetail(
          orderId: widget.orderId,
          accessToken: userController.accessToken,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final order = orderController.selectedOrder.value;
        final isLoading = orderController.isLoadingDetail.value;
        
        if (isLoading) {
          return _buildLoadingState();
        }
        
        if (order == null) {
          return _buildErrorState();
        }
        
        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
              title: const Text(
                'Order Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    _shareOrderDetails(order);
                  },
                ),
                if (order.canReorder)
                  IconButton(
                    icon: const Icon(Icons.replay),
                    onPressed: () {
                      _reorder(order);
                    },
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        TColor.primary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Order Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Order Status Timeline
                  _buildOrderStatusTimeline(order),
                  
                  const SizedBox(height: 24),
                  
                  // Restaurant Info
                  _buildRestaurantCard(order),
                  
                  const SizedBox(height: 24),
                  
                  // Order Items
                  _buildOrderItems(order),
                  
                  const SizedBox(height: 24),
                  
                  // Order Summary
                  _buildOrderSummary(order),
                  
                  const SizedBox(height: 24),
                  
                  // Delivery Information
                  _buildDeliveryInfo(order),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Information
                  _buildPaymentInfo(order),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  if (!['delivered', 'cancelled', 'refunded'].contains(order.status))
                    _buildActionButtons(order),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildOrderStatusTimeline(Order order) {
    final statusSteps = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'on_the_way',
      'delivered',
    ];
    
    final currentStatusIndex = statusSteps.indexOf(order.status);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatStatus(order.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Order #${order.orderNumber}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Timeline
          Row(
            children: [
              // Timeline line
              Column(
                children: [
                  _buildTimelineDot(
                    isActive: true,
                    color: TColor.primary,
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildTimelineDot(
                    isActive: statusSteps.indexOf('confirmed') <= currentStatusIndex,
                    color: currentStatusIndex >= 1 ? TColor.primary : Colors.grey[300],
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildTimelineDot(
                    isActive: statusSteps.indexOf('preparing') <= currentStatusIndex,
                    color: currentStatusIndex >= 2 ? TColor.primary : Colors.grey[300],
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildTimelineDot(
                    isActive: statusSteps.indexOf('ready') <= currentStatusIndex,
                    color: currentStatusIndex >= 3 ? TColor.primary : Colors.grey[300],
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildTimelineDot(
                    isActive: statusSteps.indexOf('on_the_way') <= currentStatusIndex,
                    color: currentStatusIndex >= 4 ? TColor.primary : Colors.grey[300],
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildTimelineDot(
                    isActive: statusSteps.indexOf('delivered') <= currentStatusIndex,
                    color: currentStatusIndex >= 5 ? TColor.primary : Colors.grey[300],
                  ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Status labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineStep(
                      title: 'Order Placed',
                      subtitle: DateFormat('MMM dd, hh:mm a').format(order.createdAt),
                      isActive: true,
                    ),
                    const SizedBox(height: 40),
                    _buildTimelineStep(
                      title: 'Order Confirmed',
                      subtitle: order.confirmedAt != null 
                          ? DateFormat('MMM dd, hh:mm a').format(order.confirmedAt!)
                          : 'Pending',
                      isActive: currentStatusIndex >= 1,
                    ),
                    const SizedBox(height: 40),
                    _buildTimelineStep(
                      title: 'Preparing Food',
                      subtitle: order.preparingAt != null
                          ? DateFormat('MMM dd, hh:mm a').format(order.preparingAt!)
                          : 'Pending',
                      isActive: currentStatusIndex >= 2,
                    ),
                    const SizedBox(height: 40),
                    _buildTimelineStep(
                      title: 'Ready for Pickup',
                      subtitle: order.readyAt != null
                          ? DateFormat('MMM dd, hh:mm a').format(order.readyAt!)
                          : 'Pending',
                      isActive: currentStatusIndex >= 3,
                    ),
                    const SizedBox(height: 40),
                    _buildTimelineStep(
                      title: 'On the Way',
                      subtitle: order.onTheWayAt != null
                          ? 'Driver: ${order.driverName ?? "Assigned"}'
                          : 'Pending',
                      isActive: currentStatusIndex >= 4,
                    ),
                    const SizedBox(height: 40),
                    _buildTimelineStep(
                      title: 'Delivered',
                      subtitle: order.deliveredAt != null
                          ? DateFormat('MMM dd, hh:mm a').format(order.deliveredAt!)
                          : 'Estimated: ${DateFormat('hh:mm a').format(order.estimatedDeliveryTime)}',
                      isActive: currentStatusIndex >= 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineDot({
    required bool isActive,
    required Color color,
  }) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
    );
  }
  
  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRestaurantCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Restaurant Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(order.restaurantImageUrl ?? 'https://via.placeholder.com/60'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
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
                ),
                const SizedBox(height: 4),
                Text(
                  order.restaurantAddress ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Contact Button
          IconButton(
            onPressed: () {
              _contactRestaurant(order);
            },
            icon: Icon(
              Icons.phone,
              color: TColor.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderItems(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...order.items.map((item) => Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Image
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(item.menuItem.imageUrl ?? 'https://via.placeholder.com/50'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.menuItem.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (item.menuItem.description != null)
                          Text(
                            item.menuItem.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Item Price
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Special Instructions
              if (item.specialInstructions != null && item.specialInstructions!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 62),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note: ${item.specialInstructions!}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
            ],
          )).toList(),
        ],
      ),
    );
  }
  
  Widget _buildOrderSummary(Order order) {
    final subtotal = order.items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final tax = order.taxAmount ?? subtotal * 0.1; // 10% tax if not provided
    final deliveryFee = order.deliveryFee ?? 2.99;
    final discount = order.discountAmount ?? 0.0;
    final total = order.totalAmount;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Price Breakdown
          _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _buildPriceRow('Tax', '\$${tax.toStringAsFixed(2)}'),
          _buildPriceRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
          
          if (discount > 0)
            _buildPriceRow(
              'Discount',
              '-\$${discount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          
          const Divider(height: 24),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
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
    );
  }
  
  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeliveryInfo(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Delivery Address
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Delivery Address',
            value: order.deliveryAddress,
          ),
          
          const SizedBox(height: 12),
          
          // Delivery Time
          _buildInfoRow(
            icon: Icons.access_time,
            title: 'Delivery Time',
            value: order.deliveryTime != null
                ? DateFormat('MMM dd, hh:mm a').format(order.deliveryTime!)
                : 'ASAP',
          ),
          
          const SizedBox(height: 12),
          
          // Delivery Type
          _buildInfoRow(
            icon: Icons.delivery_dining,
            title: 'Delivery Type',
            value: order.deliveryType ?? 'Standard Delivery',
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentInfo(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment Method
          _buildInfoRow(
            icon: Icons.payment,
            title: 'Payment Method',
            value: order.paymentMethod ?? 'Credit Card',
          ),
          
          const SizedBox(height: 12),
          
          // Payment Status
          _buildInfoRow(
            icon: Icons.check_circle_outline,
            title: 'Payment Status',
            value: order.paymentStatus ?? 'Paid',
            valueColor: order.paymentStatus == 'paid' ? Colors.green : Colors.orange,
          ),
          
          const SizedBox(height: 12),
          
          // Transaction ID
          if (order.transactionId != null)
            _buildInfoRow(
              icon: Icons.receipt_long,
              title: 'Transaction ID',
              value: order.transactionId!,
            ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String? value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? 'Not specified',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons(Order order) {
    return Column(
      children: [
        // Cancel Order Button
        if (order.status == 'pending' || order.status == 'confirmed')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showCancelOrderDialog(order);
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Contact Support Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _contactSupport(order);
            },
            icon: const Icon(Icons.headset_mic_outlined),
            label: const Text('Contact Support'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: TColor.primary),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Share Order Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _shareOrderDetails(order);
            },
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share Order Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
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
  
  // Action Methods
  void _shareOrderDetails(Order order) {
    // Implement share functionality
    Get.snackbar(
      'Share',
      'Order details copied to clipboard',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  void _reorder(Order order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reorder'),
        content: const Text('Add all items from this order to your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implement reorder logic
              Get.snackbar(
                'Success',
                'Items added to cart',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Reorder'),
          ),
        ],
      ),
    );
  }
  
  void _contactRestaurant(Order order) {
    // Implement contact restaurant logic
    Get.snackbar(
      'Contact',
      'Calling restaurant...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
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
  
  void _contactSupport(Order order) {
    // Implement contact support logic
    Get.snackbar(
      'Support',
      'Connecting to support...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
  
  // Loading and Error States
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TColor.primary),
          const SizedBox(height: 16),
          const Text(
            'Loading order details...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
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
          const Text(
            'Order not found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'The order you\'re looking for doesn\'t exist or you don\'t have permission to view it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}