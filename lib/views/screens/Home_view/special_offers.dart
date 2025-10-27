import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/views/screens/special_offer_page.dart';

class SpecialOffersWidget extends StatelessWidget {
  const SpecialOffersWidget({super.key});

  static const List<Map<String, dynamic>> specialOffers = [
    {
      'title': 'Combo Meal 1',
      'description': 'Burger, Fries & Drink',
      'originalPrice': 15.99,
      'discountedPrice': 12.99,
      'discount': '20% OFF',
      'image': 'assets/banner1.png',
    },
    {
      'title': 'Combo Meal 2',
      'description': 'Pizza, Salad & Drink',
      'originalPrice': 18.99,
      'discountedPrice': 15.19,
      'discount': '20% OFF',
      'image': 'assets/banner2.png',
    },
    {
      'title': 'Combo Meal 3',
      'description': 'Chicken, Rice & Drink',
      'originalPrice': 14.99,
      'discountedPrice': 11.99,
      'discount': '20% OFF',
      'image': 'assets/banner3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              onPressed: () {
                Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SpecialOffersPage(),
    ),
  );
              },
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
          height: media.height*0.3,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: specialOffers.length,
            itemBuilder: (context, index) {
              final offer = specialOffers[index];
              return Container(
                width: media.width*0.7,
                margin: EdgeInsets.only(
                    right: index == specialOffers.length - 1 ? 0 : 16),
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
                            offer['image'],
                            height: media.height*0.16,
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
                              child: Text(
                                offer['discount'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  // fontSize: 10,
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
                            offer['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColor.primaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            offer['description'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                "\$${offer['discountedPrice'].toStringAsFixed(2)}",
                                style: TextStyle(
                                  // fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "\$${offer['originalPrice'].toStringAsFixed(2)}",
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
      ],
    );
  }
}
