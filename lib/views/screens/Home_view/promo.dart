import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class PromoBannerWidget extends StatefulWidget {
  const PromoBannerWidget({super.key});

  @override
  State<PromoBannerWidget> createState() => _PromoBannerWidgetState();
}

class _PromoBannerWidgetState extends State<PromoBannerWidget> {
  int _currentBanner = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  final List<Map<String, dynamic>> banners = [
    {
      'image': 'assets/banner1.png',
      'title': 'Get 30% off on your first order',
      'subtitle': 'Special Offer',
    },
    {
      'image': 'assets/banner2.png',
      'title': 'Free delivery on orders above \$25',
      'subtitle': 'Limited Time',
    },
    {
      'image': 'assets/banner3.png',
      'title': 'Weekend Special: Buy 2 Get 1 Free',
      'subtitle': 'Weekend Deal',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentBanner < banners.length - 1) {
        _currentBanner++;
      } else {
        _currentBanner = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(banners.isEmpty){
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        // Enhanced Promo Banners
        SizedBox(
          height: 165,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBanner = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = banners[index];
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
                        banner['image'],
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
                              child: Text(
                                banner['subtitle'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner['title'],
                              style: const TextStyle(
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
      ],
    );
  }
}