import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/login_response.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthService({
    required ApiClient apiClient,
    FlutterSecureStorage? secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<LoginResponse> login(String username, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final loginResponse = LoginResponse.fromJson(response.data);

    // Store auth data securely
    await _secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: loginResponse.accessToken,
    );
    await _secureStorage.write(
      key: AppConstants.userIdKey,
      value: loginResponse.userId.toString(),
    );
    await _secureStorage.write(
      key: AppConstants.usernameKey,
      value: loginResponse.username,
    );
    await _secureStorage.write(
      key: AppConstants.userRoleKey,
      value: loginResponse.role,
    );

    return loginResponse;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.userIdKey);
    await _secureStorage.delete(key: AppConstants.usernameKey);
    await _secureStorage.delete(key: AppConstants.userRoleKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    final userId = await _secureStorage.read(key: AppConstants.userIdKey);
    final username = await _secureStorage.read(key: AppConstants.usernameKey);
    final role = await _secureStorage.read(key: AppConstants.userRoleKey);

    if (userId == null || username == null || role == null) {
      return null;
    }

    return User(
      id: int.parse(userId),
      username: username,
      role: role,
    );
  }
}
