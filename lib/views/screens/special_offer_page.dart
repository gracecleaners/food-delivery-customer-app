import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class SpecialOffersPage extends StatefulWidget {
  const SpecialOffersPage({super.key});

  @override
  State<SpecialOffersPage> createState() => _SpecialOffersPageState();
}

class _SpecialOffersPageState extends State<SpecialOffersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Same offer data as in the widget
  final List<Map<String, dynamic>> _offers = [
    {
      'title': 'Combo Meal 1',
      'description': 'Burger, Fries & Drink',
      'originalPrice': 15.99,
      'discountedPrice': 12.99,
      'discount': '20% OFF',
      'image': 'assets/banner1.png',
      'category': 'Burgers',
      'restaurant': 'Burger King',
    },
    {
      'title': 'Combo Meal 2',
      'description': 'Pizza, Salad & Drink',
      'originalPrice': 18.99,
      'discountedPrice': 15.19,
      'discount': '20% OFF',
      'image': 'assets/banner2.png',
      'category': 'Pizza',
      'restaurant': 'Pizza Hut',
    },
    {
      'title': 'Combo Meal 3',
      'description': 'Chicken, Rice & Drink',
      'originalPrice': 14.99,
      'discountedPrice': 11.99,
      'discount': '20% OFF',
      'image': 'assets/banner3.png',
      'category': 'Chicken',
      'restaurant': 'KFC',
    },
    {
      'title': 'Family Bundle',
      'description': '2 Pizzas, 2 Pastas & 4 Drinks',
      'originalPrice': 35.99,
      'discountedPrice': 28.79,
      'discount': '20% OFF',
      'image': 'assets/banner1.png',
      'category': 'Pizza',
      'restaurant': 'Domino\'s',
    },
    {
      'title': 'Sushi Platter',
      'description': '30-piece Sushi Selection',
      'originalPrice': 24.99,
      'discountedPrice': 19.99,
      'discount': '20% OFF',
      'image': 'assets/banner2.png',
      'category': 'Sushi',
      'restaurant': 'Sushi Palace',
    },
    {
      'title': 'Healthy Lunch',
      'description': 'Salad, Soup & Juice',
      'originalPrice': 12.99,
      'discountedPrice': 9.99,
      'discount': '23% OFF',
      'image': 'assets/banner3.png',
      'category': 'Healthy',
      'restaurant': 'Subway',
    },
  ];

  List<Map<String, dynamic>> get filteredOffers {
    return _offers.where((offer) {
      final matchesSearch = offer['title'].toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          offer['restaurant'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' || offer['category'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<String> get categories {
    final allCategories = _offers.map((o) => o['category']).toSet().toList();
    return ['All', ...allCategories];
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
                'Special Offers',
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
        body: filteredOffers.isEmpty
            ? _buildEmptyState()
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: media.width > 600 ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  // Fixed: Increased aspect ratio to give more height to cards
                  childAspectRatio: media.width > 600 ? 1.4 : 1.6,
                ),
                itemCount: filteredOffers.length,
                itemBuilder: (context, index) {
                  return _buildOfferCard(filteredOffers[index]);
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
          hintText: 'Search offers...',
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

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return GestureDetector(
      onTap: () {
        // Navigate to offer details or restaurant
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.asset(
                        offer['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          offer['discount'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          offer['restaurant'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Offer Details
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\$${offer['discountedPrice'].toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.primary,
                                ),
                              ),
                              Text(
                                "\$${offer['originalPrice'].toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            minimumSize: const Size(80, 32),
                          ),
                          onPressed: () {
                            // Add to cart or order now
                          },
                          child: const Text(
                            'Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isEmpty
                ? 'No offers in $_selectedFilter category'
                : 'No offers found for "$_searchQuery"',
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