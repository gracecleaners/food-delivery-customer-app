class OtpRequestEmail {
  final String email;

  OtpRequestEmail({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class OtpRequestPhone {
  final String phone;

  OtpRequestPhone({required this.phone});

  Map<String, dynamic> toJson() {
    return {'phone': phone};
  }
}

class GoogleAuthRequest {
  final String idToken;

  GoogleAuthRequest({required this.idToken});

  Map<String, dynamic> toJson() {
    return {'idToken': idToken};
  }
}
