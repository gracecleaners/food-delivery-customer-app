import 'dart:convert';

import 'package:food_delivery_customer/models/menu_item.dart';

class Order {
  final String id;
  final String orderNumber;
  final String restaurantId;
  final String restaurantName;
  final String? restaurantImageUrl;
  final String? restaurantAddress;
  final String userId;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? onTheWayAt;
  final DateTime? deliveredAt;
  final DateTime estimatedDeliveryTime;
  final List<OrderItem> items;
  final String deliveryAddress;
  final DateTime? deliveryTime;
  final String? deliveryType;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? transactionId;
  final double? taxAmount;
  final double? deliveryFee;
  final double? discountAmount;
  final String? driverName;
  final String? driverPhone;
  final String? driverImageUrl;
  final String? specialInstructions;
  final bool canReorder;

  Order({
    required this.id,
    required this.orderNumber,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImageUrl,
    this.restaurantAddress,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.confirmedAt,
    this.preparingAt,
    this.readyAt,
    this.onTheWayAt,
    this.deliveredAt,
    required this.estimatedDeliveryTime,
    required this.items,
    required this.deliveryAddress,
    this.deliveryTime,
    this.deliveryType,
    this.paymentMethod,
    this.paymentStatus,
    this.transactionId,
    this.taxAmount,
    this.deliveryFee,
    this.discountAmount,
    this.driverName,
    this.driverPhone,
    this.driverImageUrl,
    this.specialInstructions,
    this.canReorder = true,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      restaurantId: json['restaurant_id'] ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      restaurantImageUrl: json['restaurant_image_url'],
      restaurantAddress: json['restaurant_address'],
      userId: json['user_id'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      confirmedAt: json['confirmed_at'] != null 
          ? DateTime.parse(json['confirmed_at'])
          : null,
      preparingAt: json['preparing_at'] != null
          ? DateTime.parse(json['preparing_at'])
          : null,
      readyAt: json['ready_at'] != null
          ? DateTime.parse(json['ready_at'])
          : null,
      onTheWayAt: json['on_the_way_at'] != null
          ? DateTime.parse(json['on_the_way_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      estimatedDeliveryTime: DateTime.parse(json['estimated_delivery_time'] ?? 
          DateTime.now().add(const Duration(minutes: 30)).toIso8601String()),
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryTime: json['delivery_time'] != null
          ? DateTime.parse(json['delivery_time'])
          : null,
      deliveryType: json['delivery_type'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      transactionId: json['transaction_id'],
      taxAmount: (json['tax_amount'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0.0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0.0).toDouble(),
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverImageUrl: json['driver_image_url'],
      specialInstructions: json['special_instructions'],
      canReorder: json['can_reorder'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'restaurant_image_url': restaurantImageUrl,
      'restaurant_address': restaurantAddress,
      'user_id': userId,
      'status': status,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'preparing_at': preparingAt?.toIso8601String(),
      'ready_at': readyAt?.toIso8601String(),
      'on_the_way_at': onTheWayAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'delivery_address': deliveryAddress,
      'delivery_time': deliveryTime?.toIso8601String(),
      'delivery_type': deliveryType,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'tax_amount': taxAmount,
      'delivery_fee': deliveryFee,
      'discount_amount': discountAmount,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'driver_image_url': driverImageUrl,
      'special_instructions': specialInstructions,
      'can_reorder': canReorder,
    };
  }

  Order copyWith({
    String? id,
    String? orderNumber,
    String? restaurantId,
    String? restaurantName,
    String? restaurantImageUrl,
    String? restaurantAddress,
    String? userId,
    String? status,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? preparingAt,
    DateTime? readyAt,
    DateTime? onTheWayAt,
    DateTime? deliveredAt,
    DateTime? estimatedDeliveryTime,
    List<OrderItem>? items,
    String? deliveryAddress,
    DateTime? deliveryTime,
    String? deliveryType,
    String? paymentMethod,
    String? paymentStatus,
    String? transactionId,
    double? taxAmount,
    double? deliveryFee,
    double? discountAmount,
    String? driverName,
    String? driverPhone,
    String? driverImageUrl,
    String? specialInstructions,
    bool? canReorder,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantImageUrl: restaurantImageUrl ?? this.restaurantImageUrl,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      preparingAt: preparingAt ?? this.preparingAt,
      readyAt: readyAt ?? this.readyAt,
      onTheWayAt: onTheWayAt ?? this.onTheWayAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryType: deliveryType ?? this.deliveryType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      transactionId: transactionId ?? this.transactionId,
      taxAmount: taxAmount ?? this.taxAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discountAmount: discountAmount ?? this.discountAmount,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverImageUrl: driverImageUrl ?? this.driverImageUrl,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      canReorder: canReorder ?? this.canReorder,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, status: $status, total: $totalAmount)';
  }
}

class OrderItem {
  final String id;
  final MenuItem menuItem;
  final int quantity;
  final double totalPrice;
  final String? specialInstructions;

  OrderItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.totalPrice,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      menuItem: MenuItem.fromJson(Map<String, dynamic>.from(json['menu_item'])),
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      specialInstructions: json['special_instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'total_price': totalPrice,
      'special_instructions': specialInstructions,
    };
  }

  OrderItem copyWith({
    String? id,
    MenuItem? menuItem,
    int? quantity,
    double? totalPrice,
    String? specialInstructions,
  }) {
    return OrderItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}