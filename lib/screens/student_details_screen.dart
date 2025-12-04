import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

String _formatDate(String rawDate) {
  final parsed = DateTime.tryParse(rawDate);
  if (parsed == null) {
    return rawDate;
  }
  return DateFormat.yMMMMd().format(parsed);
}

class StudentDetailsScreen extends ConsumerWidget {
  const StudentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = ModalRoute.of(context)?.settings.arguments as int?;
    final userAsync = ref.watch(currentUserProvider);

    if (studentId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Student not found.'),
        ),
      );
    }

    final studentAsync = ref.watch(studentDetailsProvider(studentId));
    final coursesAsync = ref.watch(coursesProvider);

    return userAsync.when(
      data: (user) => studentAsync.when(
        data: (student) {
          final courseLookup = <int, String>{
            for (final course in coursesAsync.value ?? []) course.id: course.name,
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(student.fullName),
            ),
            drawer: user != null ? AppDrawer(user: user) : null,
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Student ID: ${student.id}'),
                        const SizedBox(height: 8),
                        Text('Starting date: ${_formatDate(student.startingDate)}'),
                        if (student.numLesson != null) ...[
                          const SizedBox(height: 8),
                          Text('Lessons taken: ${student.numLesson}'),
                        ],
                        if (student.totalMoney != null) ...[
                          const SizedBox(height: 8),
                          Text('Total paid: \$${student.totalMoney!.toStringAsFixed(2)}'),
                        ],
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Courses',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        if (student.courses.isEmpty)
                          const Text('No courses assigned yet.')
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: student.courses
                                .map(
                                  (courseId) => Chip(
                                    label: Text(courseLookup[courseId] ?? 'Course #$courseId'),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance history',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        if (student.attendance == null || student.attendance!.isEmpty)
                          const Text('No attendance records yet.')
                        else
                          ...student.attendance!.map(
                            (record) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.lightBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(record.date),
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(record.isAbsent ? 'Absent' : 'Present'),
                                  if (record.reason != null && record.reason!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('Reason: ${record.reason}'),
                                  ],
                                  if (record.chargeMoney != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Charged: ${record.chargeMoney! ? 'Yes' : 'No'}'),
                                  ],
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text('Failed to load student: $error'),
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Failed to load user: $error'),
        ),
      ),
    );
  }
}
