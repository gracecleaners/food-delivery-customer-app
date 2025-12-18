import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:food_delivery_customer/services/api_service.dart';
import 'package:food_delivery_customer/models/category.dart';

class CategoryController extends GetxController {
  final ApiService _apiService = Get.find();
  final GetStorage _storage = GetStorage();
  
  final RxList<Category> categories = <Category>[].obs;
  final Rxn<Category> selectedCategory = Rxn<Category>();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxString error = ''.obs;

  // Cache for categories
  final RxMap<int, Category> _categoryCache = <int, Category>{}.obs;
  final RxMap<int, List<Category>> _restaurantCategoriesCache = <int, List<Category>>{}.obs;
  final Map<int, DateTime> _categoryCacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 20);

  // Storage keys
  static const String _categoriesCacheKey = 'cached_categories';
  static const String _restaurantCategoriesCacheKey = 'cached_restaurant_categories';

  @override
  void onInit() {
    super.onInit();
    _loadCachedCategories();
    getCategories();
  }

  /// Load cached categories from storage
  void _loadCachedCategories() {
    try {
      // Load general categories cache
      final cachedCategories = _storage.read(_categoriesCacheKey);
      if (cachedCategories is Map) {
        for (final entry in cachedCategories.entries) {
          final categoryId = int.tryParse(entry.key);
          final categoryData = entry.value;
          if (categoryId != null && categoryData is Map) {
            try {
              _categoryCache[categoryId] = Category.fromJson(Map<String, dynamic>.from(categoryData));
              _categoryCacheTimestamps[categoryId] = DateTime.now().subtract(Duration(minutes: 10));
            } catch (e) {
              print('Error loading cached category $categoryId: $e');
            }
          }
        }
        print('✅ Loaded ${_categoryCache.length} cached categories from storage');
      }

      // Load restaurant categories cache
      final cachedRestaurantCategories = _storage.read(_restaurantCategoriesCacheKey);
      if (cachedRestaurantCategories is Map) {
        for (final entry in cachedRestaurantCategories.entries) {
          final restaurantId = int.tryParse(entry.key);
          final categoriesData = entry.value;
          if (restaurantId != null && categoriesData is List) {
            try {
              final categoryList = categoriesData
                  .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
                  .toList();
              _restaurantCategoriesCache[restaurantId] = categoryList;
            } catch (e) {
              print('Error loading cached categories for restaurant $restaurantId: $e');
            }
          }
        }
        print('✅ Loaded ${_restaurantCategoriesCache.length} cached restaurant categories from storage');
      }
    } catch (e) {
      print('Error loading category cache: $e');
    }
  }

  /// Save categories to storage
  Future<void> _saveCategoriesToStorage() async {
    try {
      // Save general categories
      final Map<String, dynamic> categoriesData = {};
      _categoryCache.forEach((id, category) {
        categoriesData[id.toString()] = category.toJson();
      });
      await _storage.write(_categoriesCacheKey, categoriesData);

      // Save restaurant categories
      final Map<String, dynamic> restaurantCategoriesData = {};
      _restaurantCategoriesCache.forEach((restaurantId, categories) {
        restaurantCategoriesData[restaurantId.toString()] = 
            categories.map((cat) => cat.toJson()).toList();
      });
      await _storage.write(_restaurantCategoriesCacheKey, restaurantCategoriesData);
    } catch (e) {
      print('Error saving categories to storage: $e');
    }
  }

  Future<void> getCategories({bool forceRefresh = false}) async {
    try {
      // Check if we have cached categories and they're not too old
      final now = DateTime.now();
      final hasValidCache = _categoryCache.isNotEmpty && 
          _categoryCacheTimestamps.values.every((time) => 
              now.difference(time) < _cacheDuration);

      if (hasValidCache && !forceRefresh) {
        // Use cached categories
        categories.value = _categoryCache.values.toList();
        print('✅ Using ${categories.length} cached categories');
        return;
      }

      isLoading.value = true;
      error.value = '';

      final response = await _apiService.get('restaurants/categories/');
      print('📁 Categories response type: ${response.runtimeType}');

      List<dynamic> categoriesList = [];
      
      if (response is List) {
        categoriesList = response;
      } else if (response is Map && response.containsKey('data')) {
        categoriesList = response['data'] ?? [];
      } else if (response is Map && response.containsKey('results')) {
        categoriesList = response['results'] ?? [];
      } else if (response is Map) {
        final possibleLists = response.values.where((value) => value is List).toList();
        if (possibleLists.isNotEmpty) {
          categoriesList = possibleLists.first;
        }
      }
      
      print('📁 Found ${categoriesList.length} categories');
      
      // DEBUG: Print raw JSON of first category
      if (categoriesList.isNotEmpty) {
        print('📁 RAW FIRST CATEGORY JSON:');
        print(JsonEncoder.withIndent('  ').convert(categoriesList.first));
      }
      
      final categoriesData = categoriesList
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
      
      // Update cache
      for (final category in categoriesData) {
        _categoryCache[category.id] = category;
        _categoryCacheTimestamps[category.id] = now;
      }
      
      categories.value = categoriesData;
      
      // Save to persistent storage
      await _saveCategoriesToStorage();
      
      // Debug: Print first category image info
      if (categoriesData.isNotEmpty) {
        final firstCat = categoriesData.first;
        print('📁 First category parsed data:');
        print('   - Name: ${firstCat.name}');
        print('   - imageUrl: ${firstCat.imageUrl}');
        print('   - images: ${firstCat.images}');
        print('   - mapImageUrl(): ${firstCat.mapImageUrl()}');
      }
    } catch (e) {
      error.value = 'Error fetching categories: $e';
      print('❌ Error fetching categories: $e');
      
      // Fallback to cached data
      if (_categoryCache.isNotEmpty) {
        categories.value = _categoryCache.values.toList();
        print('🔄 API failed, using ${categories.length} cached categories');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCategoryDetail(int categoryId, {bool forceRefresh = false}) async {
    try {
      // Check cache first
      final now = DateTime.now();
      final cachedTime = _categoryCacheTimestamps[categoryId];
      final isCacheValid = cachedTime != null && 
                          now.difference(cachedTime) < _cacheDuration;

      if (_categoryCache.containsKey(categoryId) && isCacheValid && !forceRefresh) {
        selectedCategory.value = _categoryCache[categoryId];
        print('✅ Using cached category details for ID: $categoryId');
        return;
      }

      isLoadingDetail.value = true;
      error.value = '';

      print('🔍 Fetching category detail for ID: $categoryId');
      final response = await _apiService.get('restaurants/categories/$categoryId/');
      print('🔍 Category detail response type: ${response.runtimeType}');
      
      // DEBUG: Print raw JSON response
      print('🔍 RAW CATEGORY DETAIL JSON:');
      print(JsonEncoder.withIndent('  ').convert(response));

      // Handle wrapped responses
      dynamic categoryData = response;
      
      if (response is Map) {
        // If response has a 'data' wrapper, unwrap it
        if (response.containsKey('data')) {
          categoryData = response['data'];
          print('🔍 Unwrapped data field');
        }
        
        final category = Category.fromJson(categoryData as Map<String, dynamic>);
        
        // Update cache
        _categoryCache[categoryId] = category;
        _categoryCacheTimestamps[categoryId] = now;
        selectedCategory.value = category;
        
        // Save to persistent storage
        await _saveCategoriesToStorage();
        
        print('🔍 Category loaded successfully:');
        print('   - ID: ${category.id}');
        print('   - Name: ${category.name}');
        print('   - Description: ${category.description}');
        print('   - imageUrl field: ${category.imageUrl}');
        print('   - images list: ${category.images}');
        print('   - images length: ${category.images?.length}');
        if (category.images != null && category.images!.isNotEmpty) {
          print('   - First image URL: ${category.images!.first.imageUrl}');
        }
        print('   - mapImageUrl(): ${category.mapImageUrl()}');
      } else {
        throw Exception('Unexpected response format for category detail: ${response.runtimeType}');
      }
    } catch (e, stackTrace) {
      error.value = 'Error fetching category detail: $e';
      print('❌ Error fetching category detail: $e');
      print('❌ Stack trace: $stackTrace');
      
      // Fallback to cache even if stale when API fails
      if (_categoryCache.containsKey(categoryId)) {
        selectedCategory.value = _categoryCache[categoryId];
        print('🔄 API failed, using cached category details');
      } else {
        rethrow;
      }
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Get categories for a specific restaurant with caching
  Future<List<Category>> getRestaurantCategories(int restaurantId, {bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (_restaurantCategoriesCache.containsKey(restaurantId) && !forceRefresh) {
        print('✅ Using cached categories for restaurant ID: $restaurantId');
        return _restaurantCategoriesCache[restaurantId]!;
      }

      print('📁 Fetching categories for restaurant ID: $restaurantId');
      final response = await _apiService.get('restaurants/restaurants/$restaurantId/categories/');
      
      List<dynamic> categoriesList = [];
      
      if (response is List) {
        categoriesList = response;
      } else if (response is Map && response.containsKey('data')) {
        categoriesList = response['data'] ?? [];
      } else if (response is Map && response.containsKey('results')) {
        categoriesList = response['results'] ?? [];
      } else if (response is Map) {
        final possibleLists = response.values.where((value) => value is List).toList();
        if (possibleLists.isNotEmpty) {
          categoriesList = possibleLists.first;
        }
      }

      final restaurantCategories = categoriesList
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();

      // Update cache
      _restaurantCategoriesCache[restaurantId] = restaurantCategories;
      await _saveCategoriesToStorage();

      print('📁 Found ${restaurantCategories.length} categories for restaurant $restaurantId');
      return restaurantCategories;
      
    } catch (e) {
      print('❌ Error fetching restaurant categories: $e');
      
      // Fallback to cache
      if (_restaurantCategoriesCache.containsKey(restaurantId)) {
        return _restaurantCategoriesCache[restaurantId]!;
      }
      rethrow;
    }
  }

  /// Preload multiple categories in background
  Future<void> preloadCategories(List<int> categoryIds) async {
    try {
      for (final categoryId in categoryIds) {
        if (!_categoryCache.containsKey(categoryId) || _isCacheStale(categoryId)) {
          // Load in background without awaiting
          _apiService.get('restaurants/categories/$categoryId/')
            .then((response) {
              if (response is Map) {
                dynamic categoryData = response;
                if (response.containsKey('data')) {
                  categoryData = response['data'];
                }
                final category = Category.fromJson(categoryData as Map<String, dynamic>);
                _categoryCache[categoryId] = category;
                _categoryCacheTimestamps[categoryId] = DateTime.now();
                _saveCategoriesToStorage();
                print('✅ Preloaded category: ${category.name}');
              }
            })
            .catchError((e) {
              print('❌ Failed to preload category $categoryId: $e');
            });
        }
      }
    } catch (e) {
      print('Error preloading categories: $e');
    }
  }

  /// Preload popular categories (first 10)
  Future<void> preloadPopularCategories() async {
    if (categories.isNotEmpty) {
      final popularCategoryIds = categories.take(10).map((cat) => cat.id).toList();
      await preloadCategories(popularCategoryIds);
    }
  }

  /// Check if cache is stale for a category
  bool _isCacheStale(int categoryId) {
    final cachedTime = _categoryCacheTimestamps[categoryId];
    if (cachedTime == null) return true;
    return DateTime.now().difference(cachedTime) > _cacheDuration;
  }

  /// Get category from cache (useful for quick access)
  Category? getCachedCategory(int categoryId) {
    if (_categoryCache.containsKey(categoryId) && !_isCacheStale(categoryId)) {
      return _categoryCache[categoryId];
    }
    return null;
  }

  /// Clear cache methods
  void clearCategoryCache() {
    _categoryCache.clear();
    _restaurantCategoriesCache.clear();
    _categoryCacheTimestamps.clear();
    _storage.remove(_categoriesCacheKey);
    _storage.remove(_restaurantCategoriesCacheKey);
  }

  void clearStaleCategories() {
    final now = DateTime.now();
    final staleIds = _categoryCacheTimestamps.entries
      .where((entry) => now.difference(entry.value) > _cacheDuration)
      .map((entry) => entry.key)
      .toList();

    for (final id in staleIds) {
      _categoryCache.remove(id);
      _categoryCacheTimestamps.remove(id);
    }

    _saveCategoriesToStorage();
    print('🧹 Cleared ${staleIds.length} stale categories from cache');
  }

  /// Force refresh a specific category
  Future<void> refreshCategory(int categoryId) async {
    await getCategoryDetail(categoryId, forceRefresh: true);
  }

  // Getters for cache info
  int get cachedCategoriesCount => _categoryCache.length;
  List<int> get cachedCategoryIds => _categoryCache.keys.toList();
}