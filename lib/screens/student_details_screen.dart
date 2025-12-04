import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../../widgets/app_drawer.dart';

String _formatDate(String rawDate) {
  final parsed = DateTime.tryParse(rawDate);
  if (parsed == null) {
    return rawDate;
  }
  return DateFormat.yMMMMd().format(parsed);
}

String _getInitials(String fullName) {
  final parts = fullName.split(' ');
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
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
              title: const Text('Student Details'),
            ),
            drawer: user != null ? AppDrawer(user: user) : null,
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(student.fullName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.fullName,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${student.id}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.mutedBackground(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Starting Date', _formatDate(student.startingDate)),
                              if (student.numLesson != null) ...[
                                const SizedBox(height: 8),
                                _buildInfoRow('Lessons Taken', '${student.numLesson}'),
                              ],
                              if (student.totalMoney != null) ...[
                                const SizedBox(height: 8),
                                _buildInfoRow('Total Paid', '\$${student.totalMoney!.toStringAsFixed(2)}'),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Courses',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (student.courses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No courses assigned yet.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: student.courses
                                .map(
                                  (courseId) => Chip(
                                    label: Text(courseLookup[courseId] ?? 'Course #$courseId'),
                                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                    labelStyle: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance History',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (student.attendance == null || student.attendance!.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No attendance records yet.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: student.attendance!
                                .map(
                                  (record) => Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: record.isAbsent
                                          ? Colors.red.withOpacity(0.05)
                                          : Colors.green.withOpacity(0.05),
                                      border: Border(
                                        left: BorderSide(
                                          width: 4,
                                          color: record.isAbsent ? Colors.red : Colors.green,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDate(record.date),
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                record.isAbsent ? 'Absent' : 'Present',
                                              ),
                                              backgroundColor: record.isAbsent
                                                  ? Colors.red.withOpacity(0.2)
                                                  : Colors.green.withOpacity(0.2),
                                              labelStyle: TextStyle(
                                                color: record.isAbsent ? Colors.red : Colors.green,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (record.reason != null && record.reason!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Reason: ${record.reason}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                        if (record.chargeMoney != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Charged: ${record.chargeMoney! ? 'Yes' : 'No'}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
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

  static Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
