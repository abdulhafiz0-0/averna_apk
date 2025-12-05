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

String _initials(String fullName) {
  final parts = fullName.split(' ').where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return 'S';
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts[0][0].toUpperCase();
}

class StudentDetailsScreen extends ConsumerWidget {
  const StudentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = ModalRoute.of(context)?.settings.arguments as int?;
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final secondaryText = AppTheme.secondaryTextColorFor(context);

    if (studentId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F8),
        body: Center(
          child: Text('Student not found.', style: theme.textTheme.titleMedium),
        ),
      );
    }

    final studentAsync = ref.watch(studentDetailsProvider(studentId));
    final coursesAsync = ref.watch(coursesProvider);

    return userAsync.when(
      data: (user) => studentAsync.when(
        data: (student) {
          final courseLookup = <int, String>{
            for (final course in coursesAsync.value ?? [])
              course.id: course.name,
          };

          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F8),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Student details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            drawer: user != null ? AppDrawer(user: user) : null,
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              theme.brightness == Brightness.dark ? 0.35 : 0.06,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppTheme.primaryBlue.withOpacity(
                              0.12,
                            ),
                            child: Text(
                              _initials(student.fullName),
                              style: const TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
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
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${student.id}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Start: ${_formatDate(student.startingDate)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              label: 'Lessons',
                              value: student.numLesson?.toString() ?? '—',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatTile(
                              label: 'Total paid',
                              value: student.totalMoney != null
                                  ? '\$${student.totalMoney!.toStringAsFixed(2)}'
                                  : '—',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Courses
                    _SectionCard(
                      title: 'Courses',
                      child: student.courses.isEmpty
                          ? Text(
                              'No courses assigned yet.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: secondaryText,
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: student.courses
                                  .map(
                                    (courseId) => Chip(
                                      label: Text(
                                        courseLookup[courseId] ??
                                            'Course #$courseId',
                                      ),
                                      backgroundColor: AppTheme.primaryBlue
                                          .withOpacity(0.08),
                                      labelStyle: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppTheme.primaryBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Attendance
                    _SectionCard(
                      title: 'Attendance history',
                      child:
                          (student.attendance == null ||
                              student.attendance!.isEmpty)
                          ? Text(
                              'No attendance records yet.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: secondaryText,
                              ),
                            )
                          : Column(
                              children: student.attendance!.map((record) {
                                final statusText = record.isAbsent
                                    ? 'Absent'
                                    : 'Present';
                                final statusColor = record.isAbsent
                                    ? Colors.redAccent
                                    : Colors.green;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDate(record.date),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (record.reason != null &&
                                          record.reason!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Reason: ${record.reason}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(color: secondaryText),
                                        ),
                                      ],
                                      if (record.chargeMoney != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Charged: ${record.chargeMoney! ? 'Yes' : 'No'}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(color: secondaryText),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Failed to load student: $error')),
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          const Scaffold(body: Center(child: Text('Failed to load user'))),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryText = AppTheme.secondaryTextColorFor(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: theme.textTheme.bodyMedium!.copyWith(color: secondaryText),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryText = AppTheme.secondaryTextColorFor(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.lightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
