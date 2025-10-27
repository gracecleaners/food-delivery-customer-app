import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class PopularRestaurantsPage extends StatefulWidget {
  const PopularRestaurantsPage({super.key});

  @override
  State<PopularRestaurantsPage> createState() => _PopularRestaurantsPageState();
}

class _PopularRestaurantsPageState extends State<PopularRestaurantsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Same restaurant data as in the widget
  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'Burger King',
      'rating': 4.8,
      'deliveryTime': '15-25 min',
      'image': 'assets/restaurant1.png',
      'tags': ['Burgers', 'American', 'Fast Food'],
      'category': 'Fast Food',
    },
    {
      'name': 'Pizza Hut',
      'rating': 4.5,
      'deliveryTime': '20-30 min',
      'image': 'assets/restaurant2.png',
      'tags': ['Pizza', 'Italian', 'Pasta'],
      'category': 'Italian',
    },
    {
      'name': 'Sushi Palace',
      'rating': 4.7,
      'deliveryTime': '25-35 min',
      'image': 'assets/restaurant3.png',
      'tags': ['Japanese', 'Sushi', 'Asian'],
      'category': 'Asian',
    },
    {
      'name': 'KFC',
      'rating': 4.6,
      'deliveryTime': '18-28 min',
      'image': 'assets/restaurant1.png',
      'tags': ['Chicken', 'Fast Food', 'American'],
      'category': 'Fast Food',
    },
    {
      'name': 'Subway',
      'rating': 4.4,
      'deliveryTime': '12-22 min',
      'image': 'assets/restaurant2.png',
      'tags': ['Sandwiches', 'Healthy', 'Fast Food'],
      'category': 'Healthy',
    },
    {
      'name': 'Taco Bell',
      'rating': 4.3,
      'deliveryTime': '15-25 min',
      'image': 'assets/restaurant3.png',
      'tags': ['Mexican', 'Tacos', 'Fast Food'],
      'category': 'Mexican',
    },
    {
      'name': 'Dominos',
      'rating': 4.5,
      'deliveryTime': '20-30 min',
      'image': 'assets/restaurant1.png',
      'tags': ['Pizza', 'Fast Food', 'American'],
      'category': 'Fast Food',
    },
  ];

  List<Map<String, dynamic>> get filteredRestaurants {
    return _restaurants.where((restaurant) {
      final matchesSearch = restaurant['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' || restaurant['category'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<String> get categories {
    final allCategories = _restaurants.map((r) => r['category']).toSet().toList();
    return ['All', ...allCategories];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Popular Restaurants',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColor.primaryText,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(110),
                child: Column(
                  children: [
                    // Search Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildSearchField(),
                    ),
                    
                    // Filter Chips
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedFilter == category,
                              selectedColor: TColor.primary.withOpacity(0.2),
                              backgroundColor: Colors.grey[200],
                              labelStyle: TextStyle(
                                color: _selectedFilter == category 
                                    ? TColor.primary 
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = selected ? category : 'All';
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                  return _buildRestaurantCard(filteredRestaurants[index]);
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
          hintText: 'Search restaurants...',
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
          });
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
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
              child: Stack(
                children: [
                  Image.asset(
                    restaurant['image'],
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),)
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, 
                            color: Colors.amber, 
                            size: 16),
                          const SizedBox(width: 4),
                          Text(
                            restaurant['rating'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Restaurant Info
            Padding(
              padding: const EdgeInsets.all(16),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurant['category'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: TColor.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(
                      restaurant['tags'].length > 3 ? 3 : restaurant['tags'].length,
                      (tagIndex) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: TColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            restaurant['tags'][tagIndex],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: TColor.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Delivery Info
                  Row(
                    children: [
                      Icon(Icons.delivery_dining, 
                        color: TColor.primary, 
                        size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Free delivery",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, 
                        color: TColor.primary, 
                        size: 18),
                      const SizedBox(width: 6),
                      Text(
                        restaurant['deliveryTime'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
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
            _searchQuery.isEmpty
                ? 'No restaurants in $_selectedFilter category'
                : 'No restaurants found for "$_searchQuery"',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
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