class OtpVerifyEmail {
  final String email;
  final String otp;

  OtpVerifyEmail({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}

class OtpVerifyPhone {
  final String phone;
  final String otp;

  OtpVerifyPhone({required this.phone, required this.otp});

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'otp': otp};
  }
}


class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
