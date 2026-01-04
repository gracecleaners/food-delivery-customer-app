import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/category_controller.dart';
import 'package:food_delivery_customer/models/menu_item.dart';
import 'package:food_delivery_customer/views/screens/item_detail.dart';
import 'package:food_delivery_customer/services/api_service.dart';
import 'package:get/get.dart';

class CategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  
  const CategoryPage({
    super.key, 
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final CategoryController categoryController = Get.find();
  final ApiService _apiService = Get.find();
  
  String _searchQuery = '';
  bool _isSearching = false;
  final RxList<MenuItem> _categoryMenuItems = <MenuItem>[].obs;
  final RxBool _isLoadingMenuItems = false.obs;

  @override
  void initState() {
    super.initState();
    print('🔵 CategoryPage initState - categoryId: ${widget.categoryId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoryMenuItems();
    });
  }

  Future<void> _loadCategoryMenuItems() async {
    try {
      _isLoadingMenuItems.value = true;
      print('🔍 Loading menu items for category: ${widget.categoryId}');
      
      // Try the category-specific endpoint first
      try {
        final response = await _apiService.get(
          'restaurants/categories/${widget.categoryId}/items/'
        );
        
        List<dynamic> itemsList = [];
        
        if (response is List) {
          itemsList = response;
        } else if (response is Map && response.containsKey('data')) {
          itemsList = response['data'] ?? [];
        } else if (response is Map && response.containsKey('results')) {
          itemsList = response['results'] ?? [];
        }
        
        if (itemsList.isNotEmpty) {
          final menuItems = itemsList
              .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
              .where((item) => item.isAvailable)
              .toList();
          
          _categoryMenuItems.value = menuItems;
          print('✅ Loaded ${menuItems.length} menu items from category endpoint');
          return;
        }
      } catch (e) {
        print('⚠️ Category-specific endpoint not available: $e');
      }
      
      // Fallback: Fetch all menu items and filter by category
      print('🔄 Fetching all menu items and filtering by category...');
      final response = await _apiService.get('restaurants/items/');
      
      List<dynamic> itemsList = [];
      
      if (response is List) {
        itemsList = response;
      } else if (response is Map && response.containsKey('data')) {
        itemsList = response['data'] ?? [];
      } else if (response is Map && response.containsKey('results')) {
        itemsList = response['results'] ?? [];
      }
      
      print('📦 Total items fetched: ${itemsList.length}');
      
      final menuItems = itemsList
          .map((item) {
            try {
              return MenuItem.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print('❌ Error parsing menu item: $e');
              return null;
            }
          })
          .whereType<MenuItem>()
          .where((item) {
            // Filter by category
            final itemCategory = item.category;
            final matchesCategory = itemCategory == widget.categoryId;
            
            // Only show available items
            final isAvailable = item.isAvailable;
            
            if (matchesCategory) {
              print('✅ Found item: ${item.title} (category: $itemCategory)');
            }
            
            return matchesCategory && isAvailable;
          })
          .toList();
      
      _categoryMenuItems.value = menuItems;
      print('✅ Loaded ${menuItems.length} menu items for category ${widget.categoryId} after filtering');
      
      if (menuItems.isEmpty) {
        print('⚠️ No menu items found for category ${widget.categoryId}');
        print('   This could mean:');
        print('   1. No items are assigned to this category');
        print('   2. All items in this category are unavailable');
        print('   3. The category field name might be different');
      }
      
    } catch (e, stackTrace) {
      print('❌ Error loading category menu items: $e');
      print('❌ Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load menu items: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoadingMenuItems.value = false;
    }
  }

  List<MenuItem> get filteredMenuItems {
    if (_searchQuery.isEmpty) {
      return _categoryMenuItems;
    }
    
    return _categoryMenuItems.where((item) {
      final title = item.title.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Responsive grid configuration
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 3; // Tablets and larger
    if (width > 400) return 2; // Large phones
    return 2; // Small phones
  }

  double _getAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 0.78; // Tablets
    if (width > 400) return 0.80; // Large phones
    return 0.82; // Small phones
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with Category Title
          SliverAppBar(
            backgroundColor: TColor.primary,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.categoryName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildSearchField(),
              ),
            ),
          ),

          // Menu Items Grid
          Obx(() {
            if (_isLoadingMenuItems.value) {
              return _buildMenuItemsLoading();
            }
            
            if (filteredMenuItems.isEmpty) {
              return _buildEmptyState();
            }
            
            return SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  childAspectRatio: _getAspectRatio(context),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final menuItem = filteredMenuItems[index];
                    return _buildMenuItemCard(menuItem);
                  },
                  childCount: filteredMenuItems.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search ${widget.categoryName}...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.search, color: Colors.grey[500], size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 50,
            minHeight: 50,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _isSearching = value.isNotEmpty;
          });
        },
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem menuItem) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on card width
        final cardWidth = constraints.maxWidth;
        final imageHeight = cardWidth * 0.85; // Image takes 85% of card width
        final fontSize = cardWidth * 0.085; // Responsive font size
        final priceFontSize = cardWidth * 0.09;
        final buttonSize = cardWidth * 0.2;
        
        return GestureDetector(
          onTap: () {
            Get.to(() => MenuItemDetailPage(menuItemId: menuItem.id));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.12),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menu Item Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: imageHeight,
                        color: Colors.grey[100],
                        child: menuItem.imageUrl != null
                            ? Image.network(
                                menuItem.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.fastfood,
                                    color: Colors.grey[400],
                                    size: cardWidth * 0.3,
                                  );
                                },
                              )
                            : Icon(
                                Icons.fastfood,
                                color: Colors.grey[400],
                                size: cardWidth * 0.3,
                              ),
                      ),
                    ),
                    
                    // Promotion Badge
                    if (menuItem.hasActivePromotions)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: cardWidth * 0.05,
                            vertical: cardWidth * 0.025,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            menuItem.activePromotions.first.formattedDiscount,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize * 0.75,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Menu Item Info
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(cardWidth * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Flexible(
                          child: Text(
                            menuItem.title,
                            style: TextStyle(
                              fontSize: fontSize.clamp(11.0, 14.0),
                              fontWeight: FontWeight.bold,
                              color: TColor.primaryText,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: cardWidth * 0.04),
                        
                        // Price and Add Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Price
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (menuItem.hasActivePromotions) ...[
                                    Text(
                                      menuItem.formattedDiscountedPrice,
                                      style: TextStyle(
                                        fontSize: priceFontSize.clamp(12.0, 15.0),
                                        fontWeight: FontWeight.bold,
                                        color: TColor.primary,
                                        height: 1.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      menuItem.formattedPrice,
                                      style: TextStyle(
                                        fontSize: (fontSize * 0.75).clamp(9.0, 11.0),
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                        height: 1.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ] else
                                    Text(
                                      menuItem.formattedPrice,
                                      style: TextStyle(
                                        fontSize: priceFontSize.clamp(12.0, 15.0),
                                        fontWeight: FontWeight.bold,
                                        color: TColor.primary,
                                        height: 1.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            
                            SizedBox(width: cardWidth * 0.04),
                            
                            // Add Button
                            Container(
                              width: buttonSize.clamp(28.0, 36.0),
                              height: buttonSize.clamp(28.0, 36.0),
                              decoration: BoxDecoration(
                                color: TColor.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: TColor.primary.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: (buttonSize * 0.6).clamp(16.0, 20.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItemsLoading() {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: _getAspectRatio(context),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.12),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width / _getCrossAxisCount(context) * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 60,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 50,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              _isSearching
                  ? 'No items found for "$_searchQuery"'
                  : 'No ${widget.categoryName} items available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (_isSearching)
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _isSearching = false;
                  });
                },
                child: Text(
                  'Clear search',
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 16,
                  ),
                ),
              )
            else
              TextButton.icon(
                onPressed: _loadCategoryMenuItems,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: TColor.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}