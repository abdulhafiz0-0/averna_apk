import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/providers.dart';
import '../core/theme.dart';

class AppDrawer extends ConsumerWidget {
  final User user;

  const AppDrawer({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    final displayName = user.fullName?.isNotEmpty == true ? user.fullName! : user.username;
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final canAccessManagement = user.isAdmin || user.isSuperadmin;
    final canAccessDashboard = canAccessManagement;
    final canAccessStudents = canAccessManagement;
    final canAccessCourses = canAccessManagement;
    final canAccessPayments = canAccessManagement;
    final canAccessAttendance = user.isTeacher || canAccessManagement;
    final canAccessArchived = canAccessManagement;
    final canAccessUsers = user.isSuperadmin;
    final dividerColor = AppTheme.borderColor(context);

    return Drawer(
      backgroundColor: theme.colorScheme.background,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 16),
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 16,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      if (user.email != null && user.email!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          user.email!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Close Drawer',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (canAccessDashboard)
                  _DrawerMenuItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                  ),
                if (canAccessStudents)
                  _DrawerMenuItem(
                    icon: Icons.people,
                    label: 'Students',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/students');
                    },
                  ),
                if (canAccessCourses)
                  _DrawerMenuItem(
                    icon: Icons.book,
                    label: 'Courses',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/courses');
                    },
                  ),
                if (canAccessAttendance)
                  _DrawerMenuItem(
                    icon: Icons.check_circle,
                    label: 'Attendance',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/attendance');
                    },
                  ),
                if (canAccessPayments)
                  _DrawerMenuItem(
                    icon: Icons.payment,
                    label: 'Payments',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/payments');
                    },
                  ),
                if (canAccessArchived) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Divider(height: 1, color: dividerColor),
                  ),
                  _DrawerMenuItem(
                    icon: Icons.archive,
                    label: 'Archived Students',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/archived');
                    },
                  ),
                ],
                if (canAccessUsers)
                  _DrawerMenuItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Manage Users',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/users');
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Divider(height: 1, color: dividerColor),
                ),
                _DrawerMenuItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    final authService = ref.read(authServiceProvider);
                    await authService.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_DrawerMenuItem> createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<_DrawerMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = widget.isDestructive ? AppTheme.errorRed : theme.colorScheme.onSurface;
    final hoverBackground = _isHovered
        ? (isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF3F4F6))
        : Colors.transparent;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hoverBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: textColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
