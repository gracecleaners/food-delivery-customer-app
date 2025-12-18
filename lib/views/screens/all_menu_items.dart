import 'package:flutter/material.dart';
import 'package:food_delivery_customer/models/menu_item.dart';
import 'package:get/get.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/restaurant_controller.dart';
import 'package:food_delivery_customer/controller/cart_controller.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/views/screens/item_detail.dart';

class AllMenuItemsPage extends StatefulWidget {
  const AllMenuItemsPage({super.key});

  @override
  State<AllMenuItemsPage> createState() => _AllMenuItemsPageState();
}

class _AllMenuItemsPageState extends State<AllMenuItemsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final restaurantController = Get.find<RestaurantController>();
  final cartController = Get.find<CartController>();
  final userController = Get.find<UserController>();

  final RxList<MenuItem> _filteredItems = <MenuItem>[].obs;
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    // Initialize with all items
    _filteredItems.value = restaurantController.menuItems;

    // Listen for search text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchQuery.value = query;
    _isSearching.value = query.isNotEmpty;

    if (query.isEmpty) {
      _filteredItems.value = restaurantController.menuItems;
      return;
    }

    final searchLower = query.toLowerCase();
    _filteredItems.value = restaurantController.menuItems.where((item) {
      // Search in title
      if (item.title.toLowerCase().contains(searchLower)) return true;

      // Search in description
      if (item.description != null &&
          item.description!.toLowerCase().contains(searchLower)) return true;

      // Search in restaurant name
      if (item.restaurantName != null &&
          item.restaurantName!.toLowerCase().contains(searchLower)) return true;

      // Search in dietary info
      if (item.dietaryInfo != null &&
          item.dietaryInfo!.toLowerCase().contains(searchLower)) return true;

      return false;
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    _isSearching.value = false;
    _searchQuery.value = '';
    _filteredItems.value = restaurantController.menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with Search
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            floating: true,
            snap: true,
            expandedHeight: 56, // Minimal height
            automaticallyImplyLeading: false, // No back arrow
            title: Row(
    children: [
      // Back Arrow
      IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () {
          Get.back();
        },
      ),
      const SizedBox(width: 8),

      // Search Field Expanded
      Expanded(child: _buildSearchField()),
    ],
  ),
            centerTitle: false,
            titleSpacing: 16, // Add some spacing
          ),

          // Search results count
          Obx(() {
            if (_searchQuery.value.isNotEmpty) {
              return SliverToBoxAdapter(
                child: _buildSearchResultsInfo(),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }),

          // Results or loading/empty state
          Obx(() {
            if (restaurantController.isLoadingMenuItemsValue) {
              return SliverToBoxAdapter(
                child: _buildLoadingState(),
              );
            }

            final items = _filteredItems;

            if (items.isEmpty && _searchQuery.value.isNotEmpty) {
              return SliverToBoxAdapter(
                child: _buildNoResultsState(),
              );
            }

            if (items.isEmpty) {
              return SliverToBoxAdapter(
                child: _buildEmptyState(),
              );
            }

            return _buildMenuItemsList(items);
          }),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 50, // Small height
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18), // More rounded
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 16, // Smaller icon
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: 'Search menu items...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 13, // Smaller font
                ),
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 13, // Smaller font
                color: Colors.black87,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                _searchFocusNode.unfocus();
              },
            ),
          ),
          Obx(() {
            if (_searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey[500],
                  size: 16, // Smaller icon
                ),
                onPressed: _clearSearch,
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              );
            }
            return const SizedBox(width: 8);
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResultsInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Search Results',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TColor.primaryText,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: TColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(() {
              return Text(
                '${_filteredItems.length} ${_filteredItems.length == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  fontSize: 11,
                  color: TColor.primary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemsList(RxList<MenuItem> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return _buildMenuItemCard(
            item,
            index == items.length - 1, // Add extra padding for last item
          );
        },
        childCount: items.length,
      ),
    );
  }

  Widget _buildMenuItemCard(
    MenuItem item,
    bool isLastItem,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, isLastItem ? 20 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => MenuItemDetailPage(menuItemId: item.id));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: item.hasImage
                        ? DecorationImage(
                            image: NetworkImage(item.safeImageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.hasImage
                      ? null
                      : Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                ),

                const SizedBox(width: 16),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: TColor.primaryText,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.formattedPrice,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColor.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      // Description
                      if (item.description != null &&
                          item.description!.isNotEmpty)
                        Text(
                          item.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 12),

                      // Add to Cart Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.isAvailable
                                ? TColor.primary
                                : Colors.grey[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: item.isAvailable
                              ? () async {
                                  if (!userController.isLoggedIn) {
                                    Get.snackbar(
                                      'Login Required',
                                      'Please login to add items to cart',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  try {
                                    await cartController.addToCart(
                                      menuItem: item,
                                      quantity: 1,
                                      accessToken: userController.accessToken,
                                    );

                                    Get.snackbar(
                                      'Success',
                                      '${item.title} added to cart',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error',
                                      'Failed to add item to cart: ${e.toString()}',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              : null,
                          child: Obx(() {
                            return cartController.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Add to Cart',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '"${_searchController.text}"',
              style: TextStyle(
                color: TColor.primary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Clear Search',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TColor.primary),
            const SizedBox(height: 16),
            Text(
              'Loading menu items...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No Menu Items Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Check back later for delicious menu items',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                restaurantController.refreshMenuItems();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
