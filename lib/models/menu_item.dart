import 'package:food_delivery_customer/models/promo.dart';

class MenuItemImage {
  final String imageUrl;

  MenuItemImage({required this.imageUrl});

  factory MenuItemImage.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return MenuItemImage(imageUrl: json['image']?.toString() ?? '');
    } else if (json is String) {
      return MenuItemImage(imageUrl: json);
    }
    return MenuItemImage(imageUrl: '');
  }
}

class MenuItem {
  final int id;
  final String title;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int category;
  final String? dietaryInfo;
  final int? prepTimeMinutes;
  final String? allergens;
  final String? categoryName;
  final String? restaurantName;
  final int? restaurantId;
  final List<MenuItemImage> images;
  final List<Promotion> promotions; // Add this line

  MenuItem({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    required this.category,
    this.dietaryInfo,
    this.prepTimeMinutes,
    this.allergens,
    this.categoryName,
    this.restaurantName,
    this.restaurantId,
    required this.images,
    required this.promotions, // Add this line
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    print('🛍️ Creating MenuItem from JSON keys: ${json.keys}');
    
    // Handle restaurant information - more robust parsing
    String? restaurantName;
    int? restaurantId;
    
    if (json['restaurant'] is int) {
      restaurantId = json['restaurant'];
    } else if (json['restaurant'] is Map) {
      final restaurantObj = json['restaurant'] as Map;
      restaurantName = restaurantObj['restaurant_name']?.toString() ?? 
                      restaurantObj['name']?.toString() ??
                      'Restaurant';
      restaurantId = _parseInt(restaurantObj['id']);
    } else {
      restaurantName = json['restaurant_name']?.toString();
      restaurantId = _parseInt(json['restaurant_id']);
    }

    // Handle images array
    List<MenuItemImage> images = [];
    if (json['images'] is List) {
      images = (json['images'] as List).map((image) {
        return MenuItemImage.fromJson(image);
      }).toList();
    }

    // Handle promotions array
    List<Promotion> promotions = [];
    if (json['promotions'] is List) {
      promotions = (json['promotions'] as List).map((promo) {
        return Promotion.fromJson(promo);
      }).toList();
    }

    // Use first image as main image if available
    String? mainImageUrl;
    if (images.isNotEmpty) {
      mainImageUrl = images.first.imageUrl;
    } else {
      mainImageUrl = json['image_url']?.toString() ?? 
                     json['image']?.toString();
    }

    return MenuItem(
      id: _parseInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? 'Unknown Item',
      description: json['description']?.toString(),
      price: _parseDouble(json['price']) ?? 0.0,
      imageUrl: mainImageUrl,
      isAvailable: json['is_available'] ?? true,
      category: _parseInt(json['category']) ?? 0,
      dietaryInfo: json['dietary_info']?.toString(),
      prepTimeMinutes: _parseInt(json['prep_time_minutes']),
      allergens: json['allergens']?.toString(),
      categoryName: json['category_name']?.toString(),
      restaurantName: restaurantName,
      restaurantId: restaurantId,
      images: images,
      promotions: promotions, // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'category': category,
      'dietary_info': dietaryInfo,
      'prep_time_minutes': prepTimeMinutes,
      'allergens': allergens,
      'category_name': categoryName,
      'restaurant_name': restaurantName,
      'restaurant_id': restaurantId,
      'images': images.map((img) => {'image': img.imageUrl}).toList(),
      'promotions': promotions.map((promo) => promo.toJson()).toList(),
    };
  }

  // Add getter for active promotions
  List<Promotion> get activePromotions {
    return promotions.where((promo) => promo.isCurrentlyActive).toList();
  }

  bool get hasActivePromotions => activePromotions.isNotEmpty;

  // Calculate discounted price
  double get discountedPrice {
    if (!hasActivePromotions) return price;
    
    // Use the highest discount from active promotions
    final highestDiscount = activePromotions
        .map((promo) => promo.discount)
        .reduce((a, b) => a > b ? a : b);
    
    return price * (1 - highestDiscount / 100);
  }

  String get formattedDiscountedPrice => '\$${discountedPrice.toStringAsFixed(2)}';

  // Safe getters for null safety
  String get safeImageUrl => imageUrl ?? '';
  bool get hasImage => safeImageUrl.isNotEmpty;
  bool get hasDietaryInfo => (dietaryInfo ?? '').isNotEmpty;
  String get safeDietaryInfo => dietaryInfo ?? '';
  String get safeDescription => description ?? 'No description available';
  String get safeRestaurantName => restaurantName ?? 'Restaurant';

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}