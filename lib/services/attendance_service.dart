import '../core/api_client.dart';

class AttendanceService {
  final ApiClient _apiClient;

  AttendanceService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<void> checkAttendance({
    required int studentId,
    required int courseId,
    required String date,
    required bool isAbsent,
    String? reason,
    bool? chargeMoney,
  }) async {
    await _apiClient.post(
      '/attendance/check',
      data: {
        'student_id': studentId,
        'course_id': courseId,
        'date': date,
        'isAbsent': isAbsent,
        if (reason != null) 'reason': reason,
        if (chargeMoney != null) 'charge_money': chargeMoney,
      },
    );
  }

  Future<void> updateAttendance({
    required int studentId,
    required String date,
    required int courseId,
    required bool isAbsent,
    String? reason,
    bool? chargeMoney,
  }) async {
    await _apiClient.put(
      '/attendance/student/$studentId',
      queryParameters: {
        'date': date,
        'course_id': courseId,
      },
      data: {
        'isAbsent': isAbsent,
        if (reason != null) 'reason': reason,
        if (chargeMoney != null) 'charge_money': chargeMoney,
      },
    );
  }

  Future<List<Map<String, dynamic>>> batchCheckAttendance(
    List<Map<String, dynamic>> attendanceRecords,
  ) async {
    final results = <Map<String, dynamic>>[];

    // Process in parallel with error handling
    await Future.wait(
      attendanceRecords.map((record) async {
        try {
          await checkAttendance(
            studentId: record['student_id'] as int,
            courseId: record['course_id'] as int,
            date: record['date'] as String,
            isAbsent: record['isAbsent'] as bool,
            reason: record['reason'] as String?,
            chargeMoney: record['charge_money'] as bool?,
          );
          results.add({'success': true, ...record});
        } catch (e) {
          results.add({'success': false, 'error': e.toString(), ...record});
        }
      }),
    );

    return results;
  }
}
