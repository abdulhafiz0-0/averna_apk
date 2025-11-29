import '../core/api_client.dart';
import '../models/student.dart';

class StudentService {
  final ApiClient _apiClient;

  StudentService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Student>> getStudents({
    int? skip,
    int? limit,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (skip != null) queryParams['skip'] = skip;
    if (limit != null) queryParams['limit'] = limit;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.get('/students/', queryParameters: queryParams);

    if (response.data is List) {
      return (response.data as List)
          .map((json) => Student.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<Student>> getArchivedStudents({
    int skip = 0,
    int limit = 1000,
  }) async {
    final response = await _apiClient.get(
      '/students/archived/',
      queryParameters: {
        'skip': skip,
        'limit': limit,
      },
    );

    if (response.data is List) {
      return (response.data as List)
          .map((json) => Student.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Student> getStudentById(int id) async {
    final response = await _apiClient.get('/students/$id');
    return Student.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Student> createStudent(Map<String, dynamic> studentData) async {
    final response = await _apiClient.post('/students/', data: studentData);
    return Student.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Student> updateStudent(int id, Map<String, dynamic> studentData) async {
    final response = await _apiClient.put('/students/$id', data: studentData);
    return Student.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteStudent(int id) async {
    await _apiClient.delete('/students/$id');
  }
}
