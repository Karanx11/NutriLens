import 'package:flutter/material.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/report/screens/report_screen.dart';
import '../../features/scanner/screens/scanner_screen.dart';
import '../../features/landing/screens/landing_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

class AppRoutes {
  static const splash = "/";
  static const landing = "/landing";
  static const login = "/login";
  static const register = "/register";
  static const dashboard = "/dashboard";
  static const scanner = "/scanner";
  static const report = "/report";
  static const history = "/history";
  static const profile = "/profile";

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    landing: (_) => const LandingScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    dashboard: (_) => const DashboardScreen(),
    scanner: (_) => const ScannerScreen(),
    report: (_) => const ReportScreen(),
    history: (_) => const HistoryScreen(),
    profile: (_) => const ProfileScreen(),
  };
}
