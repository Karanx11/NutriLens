import 'package:flutter/material.dart';

import '../../features/splash/screens/splash_screen.dart';
import '../../features/landing/screens/landing_screen.dart';

class AppRoutes {
  static const splash = "/";
  static const landing = "/landing";

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    landing: (_) => const LandingScreen(),
  };
}
