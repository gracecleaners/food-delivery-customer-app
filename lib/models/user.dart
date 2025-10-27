class User {
  final int id;
  final String email;
  final String username;
  final String? phone;
  final String userType;
  final bool isVerified;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
    required this.userType,
    required this.isVerified,
  });


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'],
      userType: json['user_type'] ?? 'customer',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'last_name': username,
      'phone': phone,
      'user_type': userType,
      'is_verified': isVerified,
    };
  }

  String get displayName => username;
}