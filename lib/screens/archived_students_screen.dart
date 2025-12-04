import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

class ArchivedStudentsScreen extends ConsumerWidget {
  const ArchivedStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagination = (skip: 0, limit: 200);
    final archivedStudentsAsync = ref.watch(archivedStudentsProvider(pagination));
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => archivedStudentsAsync.when(
        data: (students) => Scaffold(
          backgroundColor: AppTheme.lightBackground,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Archived Students'),
                Text(
                  '${students.length} student${students.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
            ],
          ),
          drawer: user != null ? AppDrawer(user: user) : null,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(archivedStudentsProvider(pagination));
            },
            child: students.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Card(
                        child: InkWell(
                          onTap: () {
                            // TODO: Show student details or restore options
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppTheme.textLight.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      student.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textSecondary,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.archive,
                                            size: 14,
                                            color: AppTheme.textLight,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'ID: ${student.id}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppTheme.textLight,
                                                ),
                                          ),
                                        ],
                                      ),
                                      if (student.courses.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.textLight.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${student.courses.length} course${student.courses.length != 1 ? 's' : ''}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: AppTheme.textLight,
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'restore',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.unarchive,
                                            size: 20,
                                            color: AppTheme.successGreen,
                                          ),
                                          SizedBox(width: 12),
                                          Text('Restore'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_forever,
                                            size: 20,
                                            color: AppTheme.errorRed,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Delete Permanently',
                                            style: TextStyle(color: AppTheme.errorRed),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'restore') {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Restore ${student.fullName} - Not implemented yet',
                                          ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(context, student.fullName);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: students.length,
                  ),
          ),
        ),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          backgroundColor: AppTheme.lightBackground,
          appBar: AppBar(
            title: const Text('Archived Students'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                const SizedBox(height: 16),
                Text('Failed to load archived students: $error'),
              ],
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

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.textLight.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.archive_outlined,
            size: 80,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'No archived students',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Archived students will appear here\nwhen you archive them from the student list',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String studentName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Permanently'),
          content: Text(
            'Are you sure you want to permanently delete $studentName? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delete functionality not implemented yet'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
