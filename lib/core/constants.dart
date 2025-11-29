class AppConstants {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://avernalc-production.up.railway.app',
  );

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
  static const String userRoleKey = 'user_role';

  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 2;

  // Pagination
  static const int defaultPageSize = 20;
  static const int archivedStudentsDefaultLimit = 1000;
}
