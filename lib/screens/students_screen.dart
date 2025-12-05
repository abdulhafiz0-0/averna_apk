import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/theme.dart';
import '../../widgets/app_drawer.dart';
import 'add_student_modal.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        final theme = Theme.of(context);
        final secondaryText = AppTheme.secondaryTextColorFor(context);
        final borderColor = AppTheme.borderColor(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F8),
          drawer: user != null ? AppDrawer(user: user) : null,
          body: SafeArea(
            child: studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (students) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.4 : 0.06,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            'Manage Students',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Admin • Roster & enrollment',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Top segmented control (Teacher / Admin, no Student)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.04)
                                  : const Color(0xFFF1F3F8),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _SegmentButton(
                                    label: 'Teacher',
                                    isSelected: false,
                                    onTap: () {},
                                  ),
                                ),
                                Expanded(
                                  child: _SegmentButton(
                                    label: 'Admin',
                                    isSelected: true,
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Students section title
                          Text(
                            'Students',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Search + Add button row
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search by name or course',
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(999),
                                      borderSide: BorderSide(
                                        color: borderColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(999),
                                      borderSide: BorderSide(
                                        color: borderColor,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? Colors.white.withOpacity(0.02)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          const AddStudentModal(),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: const Text('Add'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // List + form scrollable
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(studentsProvider);
                              },
                              child: ListView(
                                children: [
                                  if (students.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.people_outline,
                                            size: 56,
                                            color: secondaryText.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No students yet',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  color: secondaryText,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Add your first student to get started',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: secondaryText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    ...students.map((student) {
                                      final nameParts = student.fullName
                                          .split(' ')
                                          .where((e) => e.isNotEmpty)
                                          .toList();
                                      final initials = nameParts.isEmpty
                                          ? 'S'
                                          : nameParts.length >= 2
                                          ? '${nameParts[0][0]}${nameParts[1][0]}'
                                                .toUpperCase()
                                          : nameParts[0][0].toUpperCase();

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/student-details',
                                            arguments: student.id,
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withOpacity(0.04)
                                                : const Color(0xFFF7F8FC),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 22,
                                                backgroundColor: AppTheme
                                                    .primaryBlue
                                                    .withOpacity(0.12),
                                                child: Text(
                                                  initials,
                                                  style: const TextStyle(
                                                    color: AppTheme.primaryBlue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      student.fullName,
                                                      style: theme
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'ID: ${student.id}',
                                                      style: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color:
                                                                secondaryText,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: secondaryText
                                                    .withOpacity(0.4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  const SizedBox(height: 24),
                                  // Add Student form card
                                  Text(
                                    'Add Student',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.02)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Column(
                                      children: [
                                        _RoundedField(
                                          hint: 'Full name',
                                          icon: Icons.person_outline,
                                        ),
                                        const SizedBox(height: 10),
                                        _RoundedField(
                                          hint: '+1 (___) ___-____',
                                          icon: Icons.phone_outlined,
                                        ),
                                        const SizedBox(height: 10),
                                        _RoundedField(
                                          hint: 'Select course',
                                          icon: Icons.menu_book_outlined,
                                          isDropdown: true,
                                        ),
                                        const SizedBox(height: 10),
                                        _RoundedField(
                                          hint: 'YYYY-MM-DD',
                                          icon: Icons.date_range_outlined,
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {},
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                    color: borderColor,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    builder: (context) =>
                                                        const AddStudentModal(),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTheme.primaryBlue,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Save Student',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tip: Add students then assign courses and start dates.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}

// Segmented control button
class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryBlue : theme.disabledColor,
          ),
        ),
      ),
    );
  }
}

// Reusable rounded input field
class _RoundedField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isDropdown;

  const _RoundedField({
    required this.hint,
    required this.icon,
    this.isDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryText = AppTheme.secondaryTextColorFor(context);
    final borderColor = AppTheme.borderColor(context);

    return TextField(
      readOnly: isDropdown,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: secondaryText),
        suffixIcon: isDropdown
            ? const Icon(Icons.keyboard_arrow_down_rounded)
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
