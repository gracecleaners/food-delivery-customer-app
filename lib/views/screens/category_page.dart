import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  
  const CategoryPage({super.key, required this.categoryName});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Sample data - replace with your actual data source
  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'Burger King',
      'image': 'assets/restaurant1.png',
      'rating': 4.5,
      'deliveryTime': '20-30 min',
      'deliveryFee': '\$2.99',
      'categories': ['Fast Food', 'Burgers'],
    },
    {
      'name': 'McDonald\'s',
      'image': 'assets/restaurant2.png',
      'rating': 4.3,
      'deliveryTime': '15-25 min',
      'deliveryFee': '\$1.99',
      'categories': ['Fast Food', 'Burgers', 'Breakfast'],
    },
    {
      'name': 'KFC',
      'image': 'assets/restaurant3.png',
      'rating': 4.2,
      'deliveryTime': '25-35 min',
      'deliveryFee': '\$2.49',
      'categories': ['Fast Food', 'Chicken'],
    },
    {
      'name': 'Pizza Hut',
      'image': 'assets/restaurant2.png',
      'rating': 4.4,
      'deliveryTime': '30-40 min',
      'deliveryFee': '\$3.99',
      'categories': ['Fast Food', 'Pizza'],
    },
  ];

  List<Map<String, dynamic>> get filteredRestaurants {
    return _restaurants.where((restaurant) {
      final matchesCategory = restaurant['categories'].contains(widget.categoryName);
      final matchesSearch = restaurant['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && (_searchQuery.isEmpty || matchesSearch);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              toolbarHeight: 100,
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: TColor.primary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.categoryName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColor.primaryText,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSearchField(),
                ),
              ),
            ),
          ];
        },
        body: filteredRestaurants.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                itemCount: filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = filteredRestaurants[index];
                  return _buildRestaurantCard(restaurant, media);
                },
              ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search ${widget.categoryName} restaurants...',
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
            borderSide: BorderSide(color: TColor.primary, width: 2),
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

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant, Size media) {
    return GestureDetector(
      onTap: () {
        // Navigate to restaurant details
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Column(
          children: [
            // Restaurant Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                restaurant['image'],
                height: media.height * 0.1,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // Restaurant Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        restaurant['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColor.primaryText,
                        ),
                      ),
                      // Rating Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              restaurant['rating'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: TColor.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Delivery Info
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        restaurant['deliveryTime'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.delivery_dining, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        restaurant['deliveryFee'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            _isSearching
                ? 'No restaurants found for "$_searchQuery"'
                : 'No ${widget.categoryName} restaurants available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
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
            ),
        ],
      ),
    );
  }
}