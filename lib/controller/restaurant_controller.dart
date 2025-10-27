// controllers/restaurant_controller.dart
import 'package:food_delivery_customer/models/items.dart';
import 'package:food_delivery_customer/utils/api_endpoint.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantController extends GetxController {
  var restaurants = <RestaurantProfile>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  // Getter for popular restaurants (you can modify the logic as needed)
  List<RestaurantProfile> get popularRestaurants => restaurants.take(5).toList();

  @override
  void onInit() {
    super.onInit();
    getAllRestaurants();
  }

  Future<void> getAllRestaurants({String? accessToken}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.get(
        Uri.parse(ApiEndpoint.getRestaurants),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        restaurants.value = data.map((json) => RestaurantProfile.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Failed to load restaurants',
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (e) {
      error.value = e.message;
      Get.snackbar('Error', e.message);
    } catch (e) {
      error.value = 'An unexpected error occurred';
      Get.snackbar('Error', 'Failed to load restaurants');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshRestaurants() {
    getAllRestaurants();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}