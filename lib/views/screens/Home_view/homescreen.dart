import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/views/screens/Home_view/categories.dart';
import 'package:food_delivery_customer/views/screens/Home_view/popular_restaurants.dart';
import 'package:food_delivery_customer/views/screens/Home_view/promo.dart';
import 'package:food_delivery_customer/views/screens/Home_view/special_offers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
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

  Widget _buildLocationHeader() {
    return Row(
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
    );
  }

  Widget _buildSearchBar() {
    return Row(
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
    );
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
              _buildLocationHeader(),
              
              const SizedBox(height: 28),

              // Enhanced Search Bar
              _buildSearchBar(),

              const SizedBox(height: 32),

              // Categories Widget
              const CategoriesWidget(),

              const SizedBox(height: 32),

              // Promo Banner Widget
              const PromoBannerWidget(),

              const SizedBox(height: 32),

              // Popular Restaurants Widget
              const PopularRestaurantsWidget(),

              const SizedBox(height: 32),

              // Special Offers Widget
              const SpecialOffersWidget(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}