import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/theme.dart';
import '../providers/providers.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    final authService = ref.read(authServiceProvider);
    await authService.logout();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _clearCache(BuildContext context) async {
    await Hive.deleteFromDisk();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cached data cleared.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        drawer: user != null ? AppDrawer(user: user) : null,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (user != null)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(user.fullName ?? user.username),
                  subtitle: Text('Role: ${user.role}'),
                ),
              ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Dark mode'),
                    subtitle: const Text('Appearance settings will arrive soon.'),
                    value: false,
                    onChanged: null,
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services),
                    title: const Text('Clear cached data'),
                    subtitle: const Text('Removes locally stored Hive boxes.'),
                    onTap: () => _clearCache(context),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Learning Center',
                        applicationVersion: '1.0.0',
                        children: const [
                          Text('Learning Center mobile app for managing students, courses, and finance.'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorRed),
                title: const Text('Sign out'),
                textColor: AppTheme.errorRed,
                onTap: () => _logout(context, ref),
              ),
            ),
          ],
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
