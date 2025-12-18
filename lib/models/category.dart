import 'dart:convert';
import 'package:flutter/foundation.dart';

class CategoryImage {
  final String imageUrl;

  CategoryImage({required this.imageUrl});

  factory CategoryImage.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CategoryImage(imageUrl: json['image']?.toString() ?? '');
    } else if (json is String) {
      return CategoryImage(imageUrl: json);
    }
    return CategoryImage(imageUrl: '');
  }

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
  };
}

class Category {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final int? itemsCount;
  final List<CategoryImage>? images;
  final String? imageUrl;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.itemsCount = 0,
    required this.images,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Parse images array
    List<CategoryImage>? parsedImages;
    final rawImages = json['category_image'] ?? json['images'];
    
    if (rawImages is List) {
      parsedImages = rawImages.map((image) {
        return CategoryImage.fromJson(image);
      }).toList();
    }

    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image'] as String?, // keep for fallback
      isActive: json['is_active'] as bool? ?? true,
      itemsCount: json['items_count'] as int? ?? 0,
      images: parsedImages,
    );
  }

  String? mapImageUrl() {
    // First try the images array
    if (images != null && images!.isNotEmpty) {
      final firstImage = images!.first;
      if (firstImage.imageUrl.isNotEmpty) {
        return firstImage.imageUrl;
      }
    }
    // Fallback to direct imageUrl
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl;
    return null;
  }

  String get safeImageUrl => mapImageUrl() ?? '';
  bool get hasImage => safeImageUrl.isNotEmpty;

  String get itemsCountText => '$itemsCount items';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (imageUrl != null) 'image': imageUrl,
    'is_active': isActive,
    'items_count': itemsCount,
    if (images != null) 
      'images': images!.map((img) => img.toJson()).toList(),
    if (images != null)
      'category_image': images!.map((img) => img.toJson()).toList(),
  };

  @override
  String toString() => 'Category(id: $id, name: $name, imageUrl: ${mapImageUrl()})';
}