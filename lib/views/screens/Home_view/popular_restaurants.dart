// views/widgets/popular_restaurants_widget.dart
import 'package:flutter/material.dart';
import 'package:food_delivery_customer/controller/restaurant_controller.dart';
import 'package:food_delivery_customer/views/screens/popular_restuarant.dart';
import 'package:get/get.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class PopularRestaurantsWidget extends StatelessWidget {
  PopularRestaurantsWidget({super.key});

  final RestaurantController restaurantController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (restaurantController.isLoading.value) {
        return _buildLoadingWidget();
      }

      if (restaurantController.error.value.isNotEmpty) {
        return _buildErrorWidget();
      }

      final popularRestaurants = restaurantController.popularRestaurants;

      if (popularRestaurants.isEmpty) {
        return _buildEmptyWidget();
      }

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PopularRestaurantsPage(),
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
          
          // Horizontal Popular Restaurants List
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = popularRestaurants[index];
                return Container(
                  width: 250,
                  margin: EdgeInsets.only(
                    right: index == popularRestaurants.length - 1 ? 0 : 16,
                  ),
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
                            Container(
                                    height: 140,
                                    width: double.infinity,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Colors.grey[500],
                                      size: 50,
                                    ),
                                  ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
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
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      restaurant.rating?.toStringAsFixed(1) ?? '4.0',
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
                              restaurant.restaurantName ?? 'Restaurant',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: TColor.primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            
                            // Tags - using cuisine type from API
                            // if (restaurant.address != null && restaurant.address!.isNotEmpty)
                            //   Wrap(
                            //     spacing: 6,
                            //     runSpacing: 6,
                            //     children: restaurant.address!
                            //         .take(2)
                            //         .map((cuisine) => Container(
                            //               padding: const EdgeInsets.symmetric(
                            //                 horizontal: 10,
                            //                 vertical: 6,
                            //               ),
                            //               decoration: BoxDecoration(
                            //                 color: TColor.primary.withOpacity(0.1),
                            //                 borderRadius: BorderRadius.circular(12),
                            //               ),
                            //               child: Text(
                            //                 cuisine,
                            //                 style: TextStyle(
                            //                   fontSize: 12,
                            //                   fontWeight: FontWeight.w500,
                            //                   color: TColor.primary,
                            //                 ),
                            //               ),
                            //             ))
                            //         .toList(),
                            //   ),
                            const SizedBox(height: 12),
                            
                            // Delivery Info
                            Row(
                              children: [
                                Icon(
                                  Icons.delivery_dining,
                                  color: TColor.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Free delivery",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  color: TColor.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  restaurant.address,
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
    });
  }

  Widget _buildLoadingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 250,
                margin: EdgeInsets.only(right: index == 2 ? 0 : 16),
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
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 20,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 25,
                                color: Colors.grey[300],
                                margin: const EdgeInsets.only(right: 8),
                              ),
                              Container(
                                width: 60,
                                height: 25,
                                color: Colors.grey[300],
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

  Widget _buildErrorWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              onPressed: () {
                restaurantController.refreshRestaurants();
              },
              child: Text(
                "Retry",
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
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.grey[400],
                  size: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  restaurantController.error.value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    restaurantController.refreshRestaurants();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Popular Restaurants",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: TColor.primaryText,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: Colors.grey[400],
                  size: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  'No restaurants available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}