class ApiEndpoint {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  static const String requestOtpEmail = '$baseUrl/users/auth/request-otp/';
  static const String verifyOtpEmail = '$baseUrl/users/auth/verify-otp/';
  static const String googleAuth = '$baseUrl/users/auth/google/';
  static const String getRestaurants = '$baseUrl/restaurants/restaurants';
}
