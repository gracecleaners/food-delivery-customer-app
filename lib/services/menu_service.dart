import 'dart:convert';

import 'package:food_delivery_customer/models/auth_verification.dart';
import 'package:food_delivery_customer/models/items.dart';
import 'package:food_delivery_customer/utils/api_endpoint.dart';
import 'package:http/http.dart' as http;

class MenuService {
  Future<List<RestaurantProfile>> getAllRestaurants(
      {String? accessToken}) async {
    try {
      final response =
          await http.get(Uri.parse(ApiEndpoint.getRestaurants), headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken'
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RestaurantProfile.fromJson(json)).toList();
      } else {
        throw ApiException(
            message: 'Failed to load restaurants',
            statusCode: response.statusCode);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
