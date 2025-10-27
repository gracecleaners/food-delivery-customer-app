import 'package:food_delivery_customer/models/user.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  final _storage = GetStorage();
  final Rx<User?> _user = Rx<User?>(null);
  final RxString _accessToken = ''.obs;
  final RxString _refreshToken = ''.obs;

  User? get user => _user.value;
  String get accessToken => _accessToken.value;
  bool get isLoggedIn => _user.value != null && _accessToken.value.isNotEmpty;

  // keys for storage
  static const String _userKey = 'user_data';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  void onInit() {
    _loadUserFromStorage();
    super.onInit();
  }

  void _loadUserFromStorage() {
    try {
      final userData = _storage.read(_userKey);
      final accessToken = _storage.read(_accessTokenKey);
      final refreshToken = _storage.read(_refreshTokenKey);

      if (userData != null && accessToken != null) {
        _user.value = User.fromJson(userData);
        _accessToken.value = accessToken;
        _refreshToken.value = refreshToken ?? '';
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }

  void setUser(User user, String accessToken, String refreshToken) {
    _user.value = user;
    _accessToken.value = accessToken;
    _refreshToken.value = refreshToken;

    _storage.write(_userKey, user.toJson());
    _storage.write(_accessTokenKey, accessToken);
    _storage.write(_refreshTokenKey, refreshToken);
  }

  void clearUser() {
    _user.value = null;
    _accessToken.value = '';
    _refreshToken.value = '';

    _storage.remove(_userKey);
    _storage.remove(_accessTokenKey);
    _storage.remove(_refreshTokenKey);
  }
}
