import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_constants.dart';
import 'confirmation_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flight_takeoff_rounded,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.largeHeading.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.appTagline,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.home_rounded,
            label: 'Home',
            route: '/home',
            currentRoute: currentRoute,
            onTap: () => _navigate(context, '/home'),
          ),
          _DrawerItem(
            icon: Icons.checklist_rounded,
            label: 'Packing List',
            route: '/packing-list',
            currentRoute: currentRoute,
            onTap: () => _navigate(context, '/packing-list'),
          ),
          _DrawerItem(
            icon: Icons.monitor_heart_rounded,
            label: 'Packing Monitor',
            route: '/monitor',
            currentRoute: currentRoute,
            onTap: () => _navigate(context, '/monitor'),
          ),
          _DrawerItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            route: '/profile',
            currentRoute: currentRoute,
            onTap: () => _navigate(context, '/profile'),
          ),
          const Spacer(),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.exit_to_app_rounded,
            label: 'Logout',
            route: '',
            currentRoute: '',
            iconColor: AppColors.error,
            labelColor: AppColors.error,
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop();
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Logout',
      message: 'Yakin ingin keluar?',
      confirmLabel: 'Ya, Logout',
    );
    if (confirmed && context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  bool get _isSelected => route == currentRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _isSelected
                  ? AppColors.accent.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: iconColor ??
                      (_isSelected ? AppColors.accent : AppColors.textPrimary),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: AppTextStyles.bodyTextMedium.copyWith(
                    color: labelColor ??
                        (_isSelected ? AppColors.accent : AppColors.textPrimary),
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
