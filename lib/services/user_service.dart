import '../core/api_client.dart';
import '../models/user.dart';

class UserService {
  final ApiClient _apiClient;

  UserService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<User>> getUsers() async {
    final response = await _apiClient.get('/users/');

    if (response.data is List) {
      return (response.data as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<User> getUserById(int id) async {
    final response = await _apiClient.get('/users/$id');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    final response = await _apiClient.post('/users/', data: userData);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    final response = await _apiClient.put('/users/$id', data: userData);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    await _apiClient.delete('/users/$id');
  }
}
