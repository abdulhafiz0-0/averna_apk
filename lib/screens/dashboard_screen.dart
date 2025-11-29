import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../core/theme.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user.isTeacher) {
          return _TeacherDashboard(user: user);
        } else if (user.isAdmin || user.isSuperadmin) {
          return _AdminDashboard(user: user);
        }

        return const Scaffold(
          body: Center(child: Text('Unknown user role')),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error loading user: $error'),
        ),
      ),
    );
  }
}

class _AdminDashboard extends ConsumerWidget {
  final User user;

  const _AdminDashboard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard'),
            Text(
              'Overview & actions',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      drawer: AppDrawer(user: user),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats section
            statsAsync.when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stats',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    icon: Icons.people,
                    title: 'Total Students',
                    value: stats.totalStudents.toString(),
                    color: AppTheme.primaryBlue,
                  ),
                  _StatCard(
                    icon: Icons.attach_money,
                    title: 'Total Money',
                    value: '\$${stats.totalMoney.toStringAsFixed(2)}',
                    color: AppTheme.successGreen,
                  ),
                  _StatCard(
                    icon: Icons.money_off,
                    title: 'Payments Due',
                    value: '\$${stats.unpaid.toStringAsFixed(2)}',
                    color: AppTheme.warningOrange,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),

            // Shortcuts
            Text(
              'Shortcuts',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.people,
              title: 'Manage Students',
              subtitle: 'Add, edit, assign classes',
              onTap: () => Navigator.pushNamed(context, '/students'),
            ),
            _ActionCard(
              icon: Icons.book,
              title: 'Manage Courses',
              subtitle: 'Curriculum and schedules',
              onTap: () => Navigator.pushNamed(context, '/courses'),
            ),
            _ActionCard(
              icon: Icons.payment,
              title: 'Payments',
              subtitle: 'Invoices, dues, refunds',
              onTap: () => Navigator.pushNamed(context, '/payments'),
            ),
            if (user.isSuperadmin)
              _ActionCard(
                icon: Icons.admin_panel_settings,
                title: 'Manage Users',
                subtitle: 'Admins and teachers',
                onTap: () => Navigator.pushNamed(context, '/users'),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeacherDashboard extends ConsumerWidget {
  final User user;

  const _TeacherDashboard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Teacher'),
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      drawer: AppDrawer(user: user),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick stats
          Text(
            'Quick stats',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'My Classes',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Text(
            'Actions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _ActionCard(
            icon: Icons.check_circle,
            title: 'Mark Attendance',
            subtitle: 'Open today\'s roll call',
            onTap: () => Navigator.pushNamed(context, '/attendance'),
          ),
          _ActionCard(
            icon: Icons.history,
            title: 'Student History',
            subtitle: 'View records',
            onTap: () => Navigator.pushNamed(context, '/students'),
          ),
          _ActionCard(
            icon: Icons.class_,
            title: 'My Classes',
            subtitle: 'Manage class info',
            onTap: () => Navigator.pushNamed(context, '/courses'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
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
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
