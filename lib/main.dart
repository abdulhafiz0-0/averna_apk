import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/dashboard.dart';
import 'pages/students.dart';
import 'pages/courses.dart';
import 'pages/payments.dart';
import 'pages/archived.dart';
import 'pages/users.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/students': (context) => const StudentsPage(),
        '/courses': (context) => const CoursesPage(),
        '/payments': (context) => const PaymentsPage(),
        '/archived': (context) => const ArchivedStudentsPage(),
        '/users': (context) => const UsersPage(),
      },
    );
  }
}