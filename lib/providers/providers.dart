import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';
import '../services/course_service.dart';
import '../services/payment_service.dart';
import '../services/attendance_service.dart';
import '../services/stats_service.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/payment.dart';
import '../models/stats_overview.dart';

// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Navigation key for unauthorized handling
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    onUnauthorized: () {
      final navigatorKey = ref.read(navigatorKeyProvider);
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    },
    secureStorage: ref.watch(secureStorageProvider),
  );
});

// Service providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService(apiClient: ref.watch(apiClientProvider));
});

final courseServiceProvider = Provider<CourseService>((ref) {
  return CourseService(apiClient: ref.watch(apiClientProvider));
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(apiClient: ref.watch(apiClientProvider));
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(apiClient: ref.watch(apiClientProvider));
});

final statsServiceProvider = Provider<StatsService>((ref) {
  return StatsService(apiClient: ref.watch(apiClientProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(apiClient: ref.watch(apiClientProvider));
});

// Current user provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
});

// Students list provider
final studentsProvider = FutureProvider.autoDispose<List<Student>>((ref) async {
  final studentService = ref.watch(studentServiceProvider);
  return await studentService.getStudents();
});

// Archived students provider
final archivedStudentsProvider = FutureProvider.autoDispose
    .family<List<Student>, ({int skip, int limit})>((ref, params) async {
  final studentService = ref.watch(studentServiceProvider);
  return await studentService.getArchivedStudents(
    skip: params.skip,
    limit: params.limit,
  );
});

// Student details provider
final studentDetailsProvider = FutureProvider.autoDispose
    .family<Student, int>((ref, studentId) async {
  final studentService = ref.watch(studentServiceProvider);
  return await studentService.getStudentById(studentId);
});

// Courses provider
final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final courseService = ref.watch(courseServiceProvider);
  return await courseService.getCourses();
});

// Course details provider
final courseDetailsProvider = FutureProvider.autoDispose
    .family<Course, int>((ref, courseId) async {
  final courseService = ref.watch(courseServiceProvider);
  return await courseService.getCourseById(courseId);
});

// Payments provider
final paymentsProvider = FutureProvider.autoDispose
    .family<List<Payment>, int?>((ref, studentId) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return await paymentService.getPayments(studentId: studentId);
});

// Stats provider
final statsProvider = FutureProvider.autoDispose<StatsOverview>((ref) async {
  final statsService = ref.watch(statsServiceProvider);
  return await statsService.getStats();
});

// Users provider (admin/superadmin only)
final usersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUsers();
});

// Theme mode provider
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final FlutterSecureStorage _storage;
  static const _themeKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    final stored = await _storage.read(key: _themeKey);
    switch (stored) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage.write(key: _themeKey, value: mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(secureStorageProvider));
});

// Loading state provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Error message provider
final errorMessageProvider = StateProvider<String?>((ref) => null);
