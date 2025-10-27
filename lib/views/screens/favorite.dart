import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteItems = [];

  // List<Map<String, dynamic>> favoriteItems = [
  //   {
  //     'name': 'Cheese Burger',
  //     'restaurant': 'Burger King',
  //     'price': 8.99,
  //     'image': 'assets/images/burger.png',
  //     'isLiked': true,
  //   },
  //   {
  //     'name': 'Pepperoni Pizza',
  //     'restaurant': 'Pizza Hut',
  //     'price': 12.99,
  //     'image': 'assets/images/pizza.png',
  //     'isLiked': true,
  //   },
  //   {
  //     'name': 'Chicken Wings',
  //     'restaurant': 'KFC',
  //     'price': 9.50,
  //     'image': 'assets/images/wings.png',
  //     'isLiked': true,
  //   },
  // ];


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 60),
              child: Column(
                children: [
                  Text(
                    'Your Favorites',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            if (favoriteItems.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.heartCircleBolt,
                        size: 80,
                        color: TColor.primary, // Using your primary color
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: TColor.primaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Tap the heart icon on any menu item to save it here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: media.width * 0.6,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to home or menu
                          },
                          child: const Text(
                            'Explore Menu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: favoriteItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = favoriteItems[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
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
                      child: Row(
                        children: [
                          // Food Image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(item['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Food Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: TColor.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['restaurant'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${item['price'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: TColor.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Favorite Button
                          IconButton(
                            icon: Icon(
                              item['isLiked'] ? Icons.favorite : Icons.favorite_border,
                              color: TColor.primary,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                favoriteItems.removeAt(index);
                                // Alternatively toggle like status:
                                // item['isLiked'] = !item['isLiked'];
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}