import 'package:food_delivery_customer/models/user.dart';

class OtpResponse {
  final bool success;
  final String message;
  final String? email;
  final String? phone;

  OtpResponse(
      {required this.success, required this.message, this.email, this.phone});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
        success: json['success'] ?? true,
        message: json['message'] ?? 'OTP sent successfully',
        email: json['email'],
        phone: json['phone']);
  }
}

class AuthResponse {
  final String message;
  final Map<String, dynamic> tokens;
  final User user;

  AuthResponse({
    required this.message,
    required this.tokens,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('=== PARSING DJANGO AUTH RESPONSE ===');
    print('Full JSON: $json');
    
    // Extract data from Django response structure
    final message = json['message'] ?? 'Success';
    final tokens = json['tokens'] ?? {};
    final userJson = json['user'] ?? {};

    return AuthResponse(
      message: message,
      tokens: Map<String, dynamic>.from(tokens),
      user: User.fromJson(userJson),
    );
  }

  // Helper getters for easy access
  String get accessToken => tokens['access'] ?? '';
  String get refreshToken => tokens['refresh'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'tokens': tokens,
      'user': user.toJson(),
    };
  }
}
