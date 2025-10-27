  class RestaurantProfile {
    final int id;
    final String restaurantName;
    final String businessLicense;
    final String address;
    final Location? location;
    final Map<String, dynamic> openingHours;
    final double rating;
    final bool isApproved;
    final bool isActive;
    final int userId;

    RestaurantProfile({
      required this.id,
      required this.restaurantName,
      required this.businessLicense,
      required this.address,
      this.location,
      required this.openingHours,
      required this.rating,
      required this.isApproved,
      required this.isActive,
      required this.userId,
    });

    factory RestaurantProfile.fromJson(Map<String, dynamic> json) {
  return RestaurantProfile(
    id: json['id'] ?? 0,
    restaurantName: json['restaurant_name'] ?? '',
    businessLicense: json['business_license'] ?? '',
    address: json['address'] ?? '',
    location: json['location'] != null 
        ? Location.fromJson(json['location']) 
        : null,
    openingHours: json['opening_hours'] ?? {},
    rating: (json['rating'] ?? json['avg_rating'] ?? 0.0).toDouble(),
    isApproved: json['is_approved'] ?? false,
    isActive: json['is_active'] ?? true,
    userId: json['user_id'] ?? json['user'] ?? 0, // Handle both field names
  );
}

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'restaurant_name': restaurantName,
        'business_license': businessLicense,
        'address': address,
        'location': location?.toJson(),
        'opening_hours': openingHours,
        'rating': rating,
        'is_approved': isApproved,
        'is_active': isActive,
        'user': userId,
      };
    }
  }

  // ==================== LOCATION MODEL ====================

  class Location {
    final double latitude;
    final double longitude;

    Location({
      required this.latitude,
      required this.longitude,
    });

    factory Location.fromJson(Map<String, dynamic> json) {
      // Handle both GeoJSON format and simple coordinate format
      if (json['type'] == 'Point' && json['coordinates'] != null) {
        // GeoJSON format: [longitude, latitude]
        final coords = json['coordinates'] as List;
        return Location(
          longitude: (coords[0] ?? 0.0).toDouble(),
          latitude: (coords[1] ?? 0.0).toDouble(),
        );
      } else {
        // Simple format
        return Location(
          latitude: (json['latitude'] ?? 0.0).toDouble(),
          longitude: (json['longitude'] ?? 0.0).toDouble(),
        );
      }
    }

    Map<String, dynamic> toJson() {
      return {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      };
    }
  }

  // ==================== PROMOTION MODEL ====================

  class Promotion {
    final int id;
    final int restaurantId;
    final String name;
    final String description;
    final double discount;
    final DateTime startDate;
    final DateTime endDate;
    final bool isActive;
    final DateTime createdAt;

    Promotion({
      required this.id,
      required this.restaurantId,
      required this.name,
      required this.description,
      required this.discount,
      required this.startDate,
      required this.endDate,
      required this.isActive,
      required this.createdAt,
    });

    factory Promotion.fromJson(Map<String, dynamic> json) {
      return Promotion(
        id: json['id'] ?? 0,
        restaurantId: json['restaurant'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        discount: (json['discount'] ?? 0.0).toDouble(),
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        isActive: json['is_active'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'restaurant': restaurantId,
        'name': name,
        'description': description,
        'discount': discount,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
    }

    // Helper method to check if promotion is currently valid
    bool get isValid {
      final now = DateTime.now();
      return isActive && 
            now.isAfter(startDate) && 
            now.isBefore(endDate);
    }

    // Helper to get discount text
    String get discountText => '${discount.toStringAsFixed(0)}% OFF';
  }


  class MenuCategory {
    final int id;
    final int restaurantId;
    final String name;
    final String description;
    final int position;
    final bool isActive;
    final DateTime createdAt;
    final DateTime updatedAt;
    final List<MenuCategoryImage> images;

    MenuCategory({
      required this.id,
      required this.restaurantId,
      required this.name,
      required this.description,
      required this.position,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      this.images = const [],
    });

    factory MenuCategory.fromJson(Map<String, dynamic> json) {
      return MenuCategory(
        id: json['id'] ?? 0,
        restaurantId: json['restaurant'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        position: json['position'] ?? 0,
        isActive: json['is_active'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        images: json['category_image'] != null
            ? (json['category_image'] as List)
                .map((img) => MenuCategoryImage.fromJson(img))
                .toList()
            : [],
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'restaurant': restaurantId,
        'name': name,
        'description': description,
        'position': position,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'category_image': images.map((img) => img.toJson()).toList(),
      };
    }
  }

  // ==================== MENU ITEM MODEL ====================

  class MenuItem {
    final int id;
    final int restaurantId;
    final int categoryId;
    final String title;
    final String description;
    final double price;
    final bool isAvailable;
    final bool isFeatured;
    final int? prepTimeMinutes;
    final String allergens;
    final List<int> promotionIds;
    final DateTime createdAt;
    final DateTime updatedAt;
    final List<MenuItemImage> images;

    MenuItem({
      required this.id,
      required this.restaurantId,
      required this.categoryId,
      required this.title,
      required this.description,
      required this.price,
      required this.isAvailable,
      required this.isFeatured,
      this.prepTimeMinutes,
      required this.allergens,
      this.promotionIds = const [],
      required this.createdAt,
      required this.updatedAt,
      this.images = const [],
    });

    factory MenuItem.fromJson(Map<String, dynamic> json) {
      return MenuItem(
        id: json['id'] ?? 0,
        restaurantId: json['restaurant'] ?? 0,
        categoryId: json['category'] ?? 0,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0.0).toDouble(),
        isAvailable: json['is_available'] ?? true,
        isFeatured: json['is_featured'] ?? false,
        prepTimeMinutes: json['prep_time_minutes'],
        allergens: json['allergens'] ?? '',
        promotionIds: json['promotions'] != null
            ? List<int>.from(json['promotions'])
            : [],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        images: json['images'] != null
            ? (json['images'] as List)
                .map((img) => MenuItemImage.fromJson(img))
                .toList()
            : [],
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'restaurant': restaurantId,
        'category': categoryId,
        'title': title,
        'description': description,
        'price': price,
        'is_available': isAvailable,
        'is_featured': isFeatured,
        'prep_time_minutes': prepTimeMinutes,
        'allergens': allergens,
        'promotions': promotionIds,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'images': images.map((img) => img.toJson()).toList(),
      };
    }

    // Helper to get formatted price
    String get formattedPrice => 'UGX ${price.toStringAsFixed(0)}';

    // Helper to get allergen list
    List<String> get allergenList {
      if (allergens.isEmpty) return [];
      return allergens.split(',').map((e) => e.trim()).toList();
    }

    // Helper to check if item has discount
    bool get hasDiscount => promotionIds.isNotEmpty;
  }

  // ==================== MENU ITEM IMAGE MODEL ====================

  class MenuItemImage {
    final int id;
    final int menuItemId;
    final String image;
    final String altText;

    MenuItemImage({
      required this.id,
      required this.menuItemId,
      required this.image,
      required this.altText,
    });

    factory MenuItemImage.fromJson(Map<String, dynamic> json) {
      return MenuItemImage(
        id: json['id'] ?? 0,
        menuItemId: json['menu_item'] ?? 0,
        image: json['image'] ?? '',
        altText: json['alt_text'] ?? '',
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'menu_item': menuItemId,
        'image': image,
        'alt_text': altText,
      };
    }

    // Helper to get full image URL
    String getImageUrl(String baseUrl) {
      if (image.startsWith('http')) return image;
      return '$baseUrl$image';
    }
  }

  // ==================== MENU CATEGORY IMAGE MODEL ====================

  class MenuCategoryImage {
    final int id;
    final int categoryId;
    final String image;
    final String altText;

    MenuCategoryImage({
      required this.id,
      required this.categoryId,
      required this.image,
      required this.altText,
    });

    factory MenuCategoryImage.fromJson(Map<String, dynamic> json) {
      return MenuCategoryImage(
        id: json['id'] ?? 0,
        categoryId: json['category'] ?? 0,
        image: json['image'] ?? '',
        altText: json['alt_text'] ?? '',
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'category': categoryId,
        'image': image,
        'alt_text': altText,
      };
    }

    // Helper to get full image URL
    String getImageUrl(String baseUrl) {
      if (image.startsWith('http')) return image;
      return '$baseUrl$image';
    }
  }