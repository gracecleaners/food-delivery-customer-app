import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class PopularRestaurantsWidget extends StatelessWidget {
  const PopularRestaurantsWidget({super.key});

  static const List<Map<String, dynamic>> popularRestaurants = [
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}