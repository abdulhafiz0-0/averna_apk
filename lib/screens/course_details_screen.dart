import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/course.dart';
import '../providers/providers.dart';

class CourseDetailsScreen extends ConsumerStatefulWidget {
  final int courseId;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  static const List<String> _weekDayOptions = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedWeekDays = <String>{};
  final NumberFormat _currencyFormatter = NumberFormat.simpleCurrency();

  late TextEditingController _courseNameController;
  late TextEditingController _priceController;
  late TextEditingController _lessonsController;

  bool _initialized = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController();
    _priceController = TextEditingController();
    _lessonsController = TextEditingController();
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _priceController.dispose();
    _lessonsController.dispose();
    super.dispose();
  }

  void _hydrateForm(Course course) {
    if (_initialized) {
      return;
    }
    _courseNameController.text = course.name;
    _priceController.text = course.cost.toStringAsFixed(2);
    _lessonsController.text = course.lessonPerMonth.toString();
    _selectedWeekDays
      ..clear()
      ..addAll(course.weekDays);
    _initialized = true;
  }

  Future<void> _saveChanges(Course course) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedWeekDays.isEmpty) {
      _showSnack('Select at least one teaching day.', isError: true);
      return;
    }

    final parsedCost = double.tryParse(_priceController.text.replaceAll(',', '').trim());
    final parsedLessons = int.tryParse(_lessonsController.text.trim());

    if (parsedCost == null || parsedLessons == null) {
      _showSnack('Enter valid cost and lessons per month values.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final payload = <String, dynamic>{
      'name': _courseNameController.text.trim(),
      'cost': parsedCost,
      'lesson_per_month': parsedLessons,
      'week_days': _selectedWeekDays.toList(),
    };

    try {
      final courseService = ref.read(courseServiceProvider);
      await courseService.updateCourse(course.id, payload);
      ref.invalidate(coursesProvider);
      ref.invalidate(courseDetailsProvider(course.id));
      _initialized = false;

      if (!mounted) {
        return;
      }
      _showSnack('Course updated successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack('Failed to update course: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDeleteCourse(Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete course'),
        content: Text('Are you sure you want to delete ${course.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteCourse(course);
    }
  }

  Future<void> _deleteCourse(Course course) async {
    setState(() => _isDeleting = true);

    try {
      final courseService = ref.read(courseServiceProvider);
      await courseService.deleteCourse(course.id);
      ref.invalidate(coursesProvider);

      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
      _showSnack('Course deleted.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack('Failed to delete course: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorRed : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailsProvider(widget.courseId));

    return courseAsync.when(
      data: (course) {
        _hydrateForm(course);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Course Details'),
                Text(
                  'Admin • ${course.name}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          body: _buildAdminTab(course),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Course Details'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                const SizedBox(height: 16),
                Text('Failed to load course: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminTab(Course course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseInfo(course),
          const SizedBox(height: 24),
          _buildEditCourseForm(course),
        ],
      ),
    );
  }

  Widget _buildCourseInfo(Course course) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Course name', course.name, icon: Icons.menu_book_outlined),
          _buildInfoRow('Tuition', _currencyFormatter.format(course.cost), icon: Icons.attach_money),
          _buildInfoRow('Lessons / month', '${course.lessonPerMonth}', icon: Icons.schedule),
          _buildInfoRow('Week days', course.weekDays.isEmpty ? 'Not set' : course.weekDays.join(', '), icon: Icons.calendar_today),
          _buildInfoRow('Assigned teacher', 'Not assigned', icon: Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCourseForm(Course course) {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit course',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'Course name',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _courseNameController,
              decoration: InputDecoration(
                hintText: 'e.g., Advanced Math',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.borderGrey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a course name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Tuition (USD)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '150.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.borderGrey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the course tuition';
                }
                final parsed = double.tryParse(value.replaceAll(',', '').trim());
                if (parsed == null) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Lessons per month',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lessonsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '8',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.borderGrey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter lessons per month';
                }
                final parsed = int.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Week days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weekDayOptions.map((day) {
                final selected = _selectedWeekDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedWeekDays.add(day);
                      } else {
                        _selectedWeekDays.remove(day);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                  checkmarkColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                    color: selected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected ? AppTheme.primaryBlue : AppTheme.borderGrey,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Select all days when this class meets.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveChanges(course),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isDeleting ? null : () => _confirmDeleteCourse(course),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.errorRed),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Delete course',
                            style: TextStyle(
                              color: AppTheme.errorRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'All changes are synced to the dashboard instantly.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
