import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class CategoriesWidget extends StatefulWidget {
  const CategoriesWidget({super.key});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> categories = [
    {'image': 'assets/fast.png', 'name': 'Fast Food'},
    {'image': 'assets/pizza.png', 'name': 'Pizza'},
    {'image': 'assets/asian.png', 'name': 'Asian'},
    {'image': 'assets/caffe.png', 'name': 'Cafe'},
    {'image': 'assets/fast.png', 'name': 'Dessert'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}