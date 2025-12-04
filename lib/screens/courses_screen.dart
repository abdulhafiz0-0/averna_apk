import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/course.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';
import 'course_details_screen.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  static const List<String> _weekDayOptions = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final _searchController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _lessonsController = TextEditingController();
  final _addCourseFormKey = GlobalKey<FormState>();
  final Set<String> _newCourseWeekDays = <String>{};
  final NumberFormat _currencyFormatter = NumberFormat.simpleCurrency();

  bool _isCreatingCourse = false;
  int? _pendingCourseId;
  String? _addCourseError;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _courseNameController.dispose();
    _priceController.dispose();
    _lessonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => coursesAsync.when(
        data: (courses) {
          final filteredCourses = _filterCourses(courses);
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Manage Courses'),
                  Text(
                    '${courses.length} course${courses.length == 1 ? '' : 's'} • Admin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            drawer: user != null ? AppDrawer(user: user) : null,
            body: RefreshIndicator(
              onRefresh: () async {
                final future = ref.refresh(coursesProvider.future);
                await future;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummary(courses),
                  const SizedBox(height: 24),
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  if (filteredCourses.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredCourses.map((course) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCourseCard(course),
                        )),
                  const SizedBox(height: 120),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _showCreateCourseModal,
              backgroundColor: AppTheme.primaryBlue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add course',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Courses'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                  const SizedBox(height: 16),
                  Text('Failed to load courses: $error'),
                ],
              ),
            ),
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

  Widget _buildSummary(List<Course> courses) {
    final totalCost = courses.fold<double>(0, (sum, course) => sum + course.cost);
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            title: 'Active courses',
            value: courses.length.toString(),
            icon: Icons.menu_book_outlined,
            iconColor: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            title: 'Avg tuition',
            value: courses.isEmpty ? '—' : _currencyFormatter.format(totalCost / courses.length),
            icon: Icons.payments_outlined,
            iconColor: AppTheme.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search courses by name or weekday',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderGrey),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  List<Course> _filterCourses(List<Course> courses) {
    final query = _searchQuery.trim();
    if (query.isEmpty) {
      return courses;
    }

    return courses.where((course) {
      final searchable = '${course.name} ${course.weekDays.join(' ')}'.toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  Widget _buildCourseCard(Course course) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: InkWell(
        onTap: () => _openCourseDetails(course.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.lessonPerMonth} lessons / month',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_pendingCourseId == course.id)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppTheme.textLight),
                      onSelected: (value) {
                        if (value == 'view') {
                          _openCourseDetails(course.id);
                        } else if (value == 'delete') {
                          _confirmDeleteCourse(course);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: ListTile(
                            leading: Icon(Icons.visibility_outlined),
                            title: Text('View details'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline, color: AppTheme.errorRed),
                            title: Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: course.weekDays.isEmpty
                    ? [
                        Chip(
                          label: const Text('No days set'),
                          backgroundColor: AppTheme.inactiveGrey,
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ]
                    : course.weekDays
                        .map((day) => Chip(
                              label: Text(day),
                              backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                              labelStyle: const TextStyle(color: AppTheme.primaryBlue),
                            ))
                        .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.attach_money,
                      label: _currencyFormatter.format(course.cost),
                      color: AppTheme.successGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.event_available_outlined,
                      label: '${course.weekDays.length} teaching day${course.weekDays.length == 1 ? '' : 's'}',
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCourseSheet(BuildContext sheetContext) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Form(
            key: _addCourseFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create course',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    IconButton(
                      onPressed: _isCreatingCourse
                          ? null
                          : () {
                              Navigator.of(sheetContext).pop();
                            },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Define the schedule and pricing for the new course.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 20),
                if (_addCourseError != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _addCourseError!,
                      style: const TextStyle(color: AppTheme.errorRed),
                    ),
                  ),
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
                    hintText: 'e.g., Algebra Fundamentals',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 16),
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
                    hintText: '120.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 16),
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
                      borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 16),
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
                    final selected = _newCourseWeekDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: selected,
                      onSelected: _isCreatingCourse
                          ? null
                          : (value) {
                              setState(() {
                                if (value) {
                                  _newCourseWeekDays.add(day);
                                } else {
                                  _newCourseWeekDays.remove(day);
                                }
                              });
                            },
                      selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: selected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: selected ? AppTheme.primaryBlue : AppTheme.borderGrey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isCreatingCourse
                            ? null
                            : () {
                                _resetAddCourseForm();
                                Navigator.of(sheetContext).pop();
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppTheme.textSecondary),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreatingCourse
                            ? null
                            : () => _createCourse(sheetContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isCreatingCourse
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save course',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Courses sync instantly with dashboards and teacher rosters.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_outlined, size: 56, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'No courses yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the “Add course” button to publish your first class.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateCourseModal() async {
    _resetAddCourseForm();
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: _buildAddCourseSheet(sheetContext),
        );
      },
    );
  }

  Future<void> _openCourseDetails(int courseId) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(courseId: courseId),
      ),
    );

    if (updated == true && mounted) {
      final future = ref.refresh(coursesProvider.future);
      await future;
    }
  }

  Future<void> _createCourse(BuildContext sheetContext) async {
    if (!_addCourseFormKey.currentState!.validate()) {
      return;
    }
    if (_newCourseWeekDays.isEmpty) {
      setState(() {
        _addCourseError = 'Select at least one teaching day.';
      });
      return;
    }

    final parsedCost = double.tryParse(_priceController.text.replaceAll(',', '').trim());
    final parsedLessons = int.tryParse(_lessonsController.text.trim());

    if (parsedCost == null || parsedLessons == null) {
      setState(() {
        _addCourseError = 'Enter valid values for tuition and lessons per month.';
      });
      return;
    }

    setState(() {
      _isCreatingCourse = true;
      _addCourseError = null;
    });

    final payload = <String, dynamic>{
      'name': _courseNameController.text.trim(),
      'cost': parsedCost,
      'lesson_per_month': parsedLessons,
      'week_days': _newCourseWeekDays.toList(),
    };

    try {
      final courseService = ref.read(courseServiceProvider);
      await courseService.createCourse(payload);
      final future = ref.refresh(coursesProvider.future);
      await future;
      if (!mounted) {
        return;
      }
      Navigator.of(sheetContext).pop();
      _resetAddCourseForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _addCourseError = 'Failed to create course: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isCreatingCourse = false);
      }
    }
  }

  Future<void> _confirmDeleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      await _deleteCourse(course);
    }
  }

  Future<void> _deleteCourse(Course course) async {
    setState(() => _pendingCourseId = course.id);
    try {
      final courseService = ref.read(courseServiceProvider);
      await courseService.deleteCourse(course.id);
      final future = ref.refresh(coursesProvider.future);
      await future;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${course.name} deleted.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete course: $error'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _pendingCourseId = null);
      }
    }
  }

  void _resetAddCourseForm() {
    _courseNameController.clear();
    _priceController.clear();
    _lessonsController.clear();
    _addCourseFormKey.currentState?.reset();
    if (!mounted) {
      _newCourseWeekDays.clear();
      _addCourseError = null;
      return;
    }
    setState(() {
      _newCourseWeekDays.clear();
      _addCourseError = null;
    });
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
