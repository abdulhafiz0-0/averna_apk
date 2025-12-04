import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../../widgets/app_drawer.dart';
import '../../models/student.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  int? _selectedCourseId;
  final Map<int, AttendanceStatus> _attendanceStatus = {};
  bool _isSubmitting = false;

  Future<void> _submit(BuildContext context) async {
    if (_selectedCourseId == null || _attendanceStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course and mark attendance.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final attendanceService = ref.read(attendanceServiceProvider);
    final formatter = DateFormat('yyyy-MM-dd');
    final dateStr = formatter.format(DateTime.now());

    try {
      for (var entry in _attendanceStatus.entries) {
        final studentId = entry.key;
        final attendanceStatus = entry.value;


        await attendanceService.checkAttendance(
          studentId: studentId,
          courseId: _selectedCourseId!,
          date: dateStr,
          isAbsent: attendanceStatus.type == AttendanceType.absentUnexcused,
          reason: attendanceStatus.reason ?? '',
          chargeMoney: attendanceStatus.type == AttendanceType.absentUnexcused,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance submitted successfully.')),
      );
      setState(() {
        _attendanceStatus.clear();
        _selectedCourseId = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit attendance: $error')),
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

    final now = DateTime.now();
    final timeLabel = DateFormat('EEEE, h:mm a').format(now);

    return userAsync.when(
      data: (user) {
        if (studentsAsync.isLoading || coursesAsync.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (studentsAsync.hasError || coursesAsync.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Attendance')),
            body: Center(
              child: Text('Failed to load data'),
            ),
          );
        }

        final students = studentsAsync.value ?? [];
        final courses = coursesAsync.value ?? [];

        final selectedCourse = _selectedCourseId != null
            ? courses.where((c) => c.id == _selectedCourseId).firstOrNull
            : null;

        final studentsInCourse = _selectedCourseId != null
            ? students
                .where((s) => s.courses.contains(_selectedCourseId))
                .toList()
            : [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Attendance'),
          ),
          drawer: user != null ? AppDrawer(user: user) : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedCourseId,
                    decoration: InputDecoration(
                      labelText: 'Select Course',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
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
                        _attendanceStatus.clear();
                      });
                    },
                  ),
                ),
                if (_selectedCourseId != null && selectedCourse != null) ...[
                  Container(
                    color: const Color(0xFFDFE9F8),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCourse.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mark attendance',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFE9F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            timeLabel,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFE9F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${studentsInCourse.length} students',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height - 350,
                    ),
                    child: studentsInCourse.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'No students enrolled in this course',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: studentsInCourse.length,
                            itemBuilder: (context, index) {
                              final student = studentsInCourse[index];
                              final status = _attendanceStatus[student.id];

                              return _StudentAttendanceCard(
                                student: student,
                                status: status,
                                onStatusChanged: (newStatus) {
                                  setState(() {
                                    _attendanceStatus[student.id] = newStatus;
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          bottomNavigationBar: _selectedCourseId != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A7FD8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            _isSubmitting ? 'Submitting...' : 'Submit attendance',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All changes are saved locally until you submit.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : null,
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

enum AttendanceType { present, absentExcused, absentUnexcused }

class AttendanceStatus {
  final AttendanceType type;
  final String? reason;

  AttendanceStatus({required this.type, this.reason});
}

class _StudentAttendanceCard extends StatelessWidget {
  final Student student;
  final AttendanceStatus? status;
  final Function(AttendanceStatus) onStatusChanged;

  const _StudentAttendanceCard({
    required this.student,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final initials = student.fullName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE0E7FF),
            child: Text(
              initials,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A7FD8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${student.id}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AttendanceButton(
                  label: 'Present',
                  color: const Color(0xFF10B981),
                  isSelected: status?.type == AttendanceType.present,
                  onPressed: () => onStatusChanged(
                    AttendanceStatus(type: AttendanceType.present),
                  ),
                ),
                const SizedBox(width: 6),
                _AttendanceButton(
                  label: 'Absent',
                  color: const Color(0xFFEF4444),
                  isSelected: status?.type == AttendanceType.absentUnexcused,
                  onPressed: () => onStatusChanged(
                    AttendanceStatus(type: AttendanceType.absentUnexcused),
                  ),
                ),
                const SizedBox(width: 6),
                _AttendanceButton(
                  label: 'Late',
                  color: const Color(0xFFFCD34D),
                  isSelected: status?.type == AttendanceType.absentExcused,
                  onPressed: () => onStatusChanged(
                    AttendanceStatus(
                      type: AttendanceType.absentExcused,
                      reason: 'Late',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;

  const _AttendanceButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
