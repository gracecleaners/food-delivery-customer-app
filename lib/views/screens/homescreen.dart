import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;
  int _selectedCategory = 0;
  int _currentBanner = 0;

  final List<Map<String, dynamic>> categories = [
    {'image': 'assets/fast.png', 'name': 'Fast Food'},
    {'image': 'assets/pizza.png', 'name': 'Pizza'},
    {'image': 'assets/asian.png', 'name': 'Asian'},
    {'image': 'assets/caffe.png', 'name': 'Cafe'},
    {'image': 'assets/fast.png', 'name': 'Dessert'},
  ];

  final List<String> banners = [
    'assets/banner1.png',
    'assets/banner2.png',
    'assets/banner3.png',
  ];

  final List<Map<String, dynamic>> popularRestaurants = [
    {
      'name': 'Burger King',
      'rating': 4.8,
      'deliveryTime': '15-25 min',
      'image': 'assets/restaurant1.png',
      'tags': ['Burgers', 'American', 'Fast Food']
    },
    {
      'name': 'Pizza Hut',
      'rating': 4.5,
      'deliveryTime': '20-30 min',
      'image': 'assets/restaurant2.png',
      'tags': ['Pizza', 'Italian', 'Pasta']
    },
    {
      'name': 'Sushi Palace',
      'rating': 4.7,
      'deliveryTime': '25-35 min',
      'image': 'assets/restaurant3.png',
      'tags': ['Japanese', 'Sushi', 'Asian']
    },
    {
      'name': 'KFC',
      'rating': 4.6,
      'deliveryTime': '18-28 min',
      'image': 'assets/restaurant1.png',
      'tags': ['Chicken', 'Fast Food', 'American']
    },
    {
      'name': 'Subway',
      'rating': 4.4,
      'deliveryTime': '12-22 min',
      'image': 'assets/restaurant2.png',
      'tags': ['Sandwiches', 'Healthy', 'Fast Food']
    },
  ];

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _unfocusSearch() {
    _focusNode.unfocus();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: media.height * 0.03),
              
              // Location and Profile with enhanced styling
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.location_on, color: TColor.primary, size: 25),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Deliver to",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Kampala, Uganda",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.primaryText,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down, color: TColor.primary, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 28),

              // Enhanced Search Bar
              Row(
                children: [
                  if (_isFocused)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: _unfocusSearch,
                        child: Icon(Icons.arrow_back_ios, color: TColor.primary, size: 18),
                      ),
                    ),
                  Expanded(
                    child: Container(
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
                        controller: _controller,
                        focusNode: _focusNode,
                        // textAlign: _isFocused ? TextAlign.start : TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'What are you craving today?',
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
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Categories Title
              Text(
                "Categories",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: TColor.primaryText,
                ),
              ),

              const SizedBox(height: 18),

              // Enhanced Categories with Images
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                      child: Container(
                        width: 85,
                        margin: EdgeInsets.only(
                          right: index == categories.length - 1 ? 0 : 16),
                        decoration: BoxDecoration(
                          color: _selectedCategory == index
                              ? TColor.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedCategory == index
                                  ? TColor.primary.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: _selectedCategory == index ? 10 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: _selectedCategory == index
                                    ? Colors.white.withOpacity(0.2)
                                    : TColor.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  categories[index]['image'],
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                  
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              categories[index]['name'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _selectedCategory == index
                                    ? Colors.white
                                    : TColor.primaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Enhanced Promo Banners
              SizedBox(
                height: 165,
                child: PageView.builder(
                  itemCount: banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBanner = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Image.asset(
                              banners[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: TColor.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Special Offer",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Get 30% off on your first order",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Enhanced Banner Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentBanner == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentBanner == index
                          ? TColor.primary
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Popular Restaurants Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Popular Restaurants",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "See all",
                      style: TextStyle(
                        color: TColor.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Horizontal Popular Restaurants List
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularRestaurants.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 250,
                      margin: EdgeInsets.only(
                        right: index == popularRestaurants.length - 1 ? 0 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Restaurant Image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Image.asset(
                                  popularRestaurants[index]['image'],
                                  height: 140,
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
                                          offset: const Offset(0, 2),
                                        ),
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
                                          popularRestaurants[index]['rating'].toString(),
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
                                Text(
                                  popularRestaurants[index]['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: TColor.primaryText,
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Tags
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: List.generate(
                                    popularRestaurants[index]['tags'].length > 2 ? 2 : popularRestaurants[index]['tags'].length,
                                    (tagIndex) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: TColor.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          popularRestaurants[index]['tags'][tagIndex],
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
                                      popularRestaurants[index]['deliveryTime'],
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
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Special Offers Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Special Offers",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "See all",
                      style: TextStyle(
                        color: TColor.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Enhanced Special Offers Horizontal List
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 270,
                      margin: EdgeInsets.only(
                        right: index == 2 ? 0 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/banner${index + 1}.png',
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "20% OFF",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Offer Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Combo Meal ${index + 1}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: TColor.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Burger, Fries & Drink",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      "\$12.99",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: TColor.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "\$15.99",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}