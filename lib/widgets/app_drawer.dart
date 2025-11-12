import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final bool isAdmin;

  const AppDrawer({
    super.key,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                const Text(
                  'User Name',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  isAdmin ? 'Administrator' : 'User',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Students'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/students');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Courses'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/courses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payments'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/payments');
            },
          ),
          if (isAdmin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archived Students'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/archived');
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Users'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/users');
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}