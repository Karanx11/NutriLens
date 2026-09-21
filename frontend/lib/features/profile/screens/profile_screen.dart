import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      // Shown as a tab inside the main shell, so there is nothing to pop.
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            padding: const EdgeInsets.all(AppSizes.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        auth.userName.isNotEmpty
                            ? auth.userName.substring(0, 1).toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.m),
                    Text(
                      auth.userName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    if (auth.userEmail.isNotEmpty)
                      Text(
                        auth.userEmail,
                        style: TextStyle(
                            color: onSurface.withValues(alpha: 0.6)),
                      ),
                    if (auth.isGuest)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusPill),
                          ),
                          child: const Text(
                            'Guest session',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.xl),
                _SectionLabel('Preferences'),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_outlined),
                        title: const Text('Dark mode'),
                        subtitle: const Text('Override system theme'),
                        value: theme.isDark,
                        onChanged: (v) =>
                            context.read<ThemeProvider>().toggleDark(v),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary:
                            const Icon(Icons.notifications_outlined),
                        title: const Text('Notifications'),
                        subtitle: const Text('Expiry & health reminders'),
                        value: _notifications,
                        onChanged: (v) =>
                            setState(() => _notifications = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.l),
                _SectionLabel('About'),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('About NutriLens'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: 'NutriLens',
                          applicationVersion: '1.0.0 (demo)',
                          applicationIcon: const Icon(Icons.eco,
                              color: AppColors.primary, size: 32),
                          children: const [
                            Text(
                              'NutriLens helps you understand what is inside '
                              'your food. This build runs a self-contained '
                              'on-device demo with simulated AI analysis.',
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.shield_outlined),
                        title: Text('Privacy'),
                        subtitle: Text('Scans stay on this device in demo mode'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
                const SizedBox(height: AppSizes.l),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.landing, (route) => false);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSizes.s),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
