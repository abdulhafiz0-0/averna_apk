import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'providers/providers.dart';
import 'pages/login.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/students_screen.dart';
import 'screens/student_details_screen.dart';
import 'screens/archived_students_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/users_screen.dart';
import 'screens/settings_screen.dart';
import 'pages/login.dart';
import 'pages/payments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.watch(navigatorKeyProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Learning Center',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: '/login',
      routes: {
        '/logins' : (context) => const LoginPage(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/students': (context) => const StudentsScreen(),
        '/student-details': (context) => const StudentDetailsScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/payments': (context) => const PaymentsScreen(),
        '/archived': (context) => const ArchivedStudentsScreen(),
        '/users': (context) => const UsersScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/login1': (context) => const LoginPage(),
        '/payments1': (context) => const PaymentsPage(),
      },
    );
  }
}