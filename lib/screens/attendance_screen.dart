import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  int? _selectedStudentId;
  int? _selectedCourseId;
  DateTime _selectedDate = DateTime.now();
  bool _isAbsent = true;
  bool _chargeMoney = false;
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (_selectedStudentId == null || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose both a student and a course.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final attendanceService = ref.read(attendanceServiceProvider);
    final formatter = DateFormat('yyyy-MM-dd');

    try {
      await attendanceService.checkAttendance(
        studentId: _selectedStudentId!,
        courseId: _selectedCourseId!,
        date: formatter.format(_selectedDate),
        isAbsent: _isAbsent,
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        chargeMoney: _chargeMoney,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved.')),
      );
      setState(() {
        _reasonController.clear();
        _isAbsent = true;
        _chargeMoney = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save attendance: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final studentsAsync = ref.watch(studentsProvider);
    final coursesAsync = ref.watch(coursesProvider);

    final dateLabel = DateFormat.yMMMMd().format(_selectedDate);

    return userAsync.when(
      data: (user) {
        if (studentsAsync.isLoading || coursesAsync.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (studentsAsync.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Attendance')),
            body: Center(
              child: Text('Failed to load students: ${studentsAsync.error}'),
            ),
          );
        }

        if (coursesAsync.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Attendance')),
            body: Center(
              child: Text('Failed to load courses: ${coursesAsync.error}'),
            ),
          );
        }

        final students = studentsAsync.value ?? [];
        final courses = coursesAsync.value ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Attendance'),
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
                        'Record attendance',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedStudentId,
                        decoration: const InputDecoration(
                          labelText: 'Student',
                        ),
                        items: students
                            .map(
                              (student) => DropdownMenuItem<int>(
                                value: student.id,
                                child: Text(student.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStudentId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedCourseId,
                        decoration: const InputDecoration(
                          labelText: 'Course',
                        ),
                        items: courses
                            .map(
                              (course) => DropdownMenuItem<int>(
                                value: course.id,
                                child: Text(course.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCourseId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Date'),
                        subtitle: Text(dateLabel),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _pickDate(context),
                      ),
                      const Divider(),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Marked absent'),
                        value: _isAbsent,
                        onChanged: (value) {
                          setState(() {
                            _isAbsent = value;
                          });
                        },
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Charge fee for absence'),
                        subtitle: const Text(
                          'Enable if the student should be charged for the missed lesson.',
                        ),
                        value: _chargeMoney,
                        onChanged: (value) {
                          setState(() {
                            _chargeMoney = value;
                          });
                        },
                      ),
                      TextField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Reason (optional)',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : () => _submit(context),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isSubmitting ? 'Saving...' : 'Save'),
                        ),
                      ),
                      if (students.isEmpty || courses.isEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Add students and courses first to record attendance.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
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
        body: Center(
          child: Text('Failed to load user: $error'),
        ),
      ),
    );
  }
}
