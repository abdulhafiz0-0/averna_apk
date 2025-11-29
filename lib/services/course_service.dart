import '../core/api_client.dart';
import '../models/course.dart';

class CourseService {
  final ApiClient _apiClient;

  CourseService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Course>> getCourses() async {
    final response = await _apiClient.get('/courses/');

    if (response.data is List) {
      return (response.data as List)
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Course> getCourseById(int id) async {
    final response = await _apiClient.get('/courses/$id');
    return Course.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Course> createCourse(Map<String, dynamic> courseData) async {
    final response = await _apiClient.post('/courses/', data: courseData);
    return Course.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Course> updateCourse(int id, Map<String, dynamic> courseData) async {
    final response = await _apiClient.put('/courses/$id', data: courseData);
    return Course.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCourse(int id) async {
    await _apiClient.delete('/courses/$id');
  }
}
