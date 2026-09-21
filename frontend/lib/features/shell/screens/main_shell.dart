import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// Persistent bottom-tab shell for the signed-in experience.
///
/// The tabs live in an [IndexedStack], so switching never pushes a route —
/// the navigation bar stays visible on every tab and each tab keeps its own
/// scroll position and state.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            onViewHistory: () => _select(1),
            onViewProfile: () => _select(2),
          ),
          const HistoryScreen(),
          const ProfileScreen(),
        ],
      ),
      // Home has its own quick-action tiles; the FAB gives History a scan
      // entry point without doubling up on Home.
      floatingActionButton: _index != 1
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.scanner),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Scan'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
