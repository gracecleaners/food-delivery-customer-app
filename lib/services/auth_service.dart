import 'dart:convert';

import 'package:food_delivery_customer/models/auth_request.dart';
import 'package:food_delivery_customer/models/auth_response.dart';
import 'package:food_delivery_customer/models/auth_verification.dart';
import 'package:food_delivery_customer/utils/api_endpoint.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // EMAIL AUTHENTICATION
  // Requesting OTP via email
  Future<OtpResponse> requestOtpEmail(String email) async {
    try {
      final response = await http.post(Uri.parse(ApiEndpoint.requestOtpEmail),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(OtpRequestEmail(email: email).toJson()));
      return _handleOtpResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // verify email otp
  Future<AuthResponse> verifyOtpEmail(String email, String otp) async {
    try{
      final response = await http.post(Uri.parse(ApiEndpoint.verifyOtpEmail),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(OtpVerifyEmail(email: email, otp: otp).toJson()));

    return _handleAuthResponse(response);
    }catch(e){
      throw _handleError(e);
    }
    
  }

  // PRIVATE HELPER METHODS
  OtpResponse _handleOtpResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return OtpResponse.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['message'] ?? error['error'] ?? 'Failed to send OTP',
        statusCode: response.statusCode,
      );
    }
  }

  AuthResponse _handleAuthResponse(http.Response response) {
  final jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    try {
      return AuthResponse.fromJson(jsonResponse);
    } catch (e) {
      print('Error parsing AuthResponse: $e');
      throw ApiException(
        message: 'Failed to parse authentication response',
        statusCode: response.statusCode,
      );
    }
  } else {
    final error = jsonDecode(response.body);
    throw ApiException(
      message: error['message'] ?? error['error'] ?? 'Authentication failed',
      statusCode: response.statusCode,
    );
  }
}

  ApiException _handleError(dynamic error) {
    if (error is ApiException) return error;
    return ApiException(
      message: 'Network error: ${error.toString()}',
      statusCode: 0,
    );
  }
}
