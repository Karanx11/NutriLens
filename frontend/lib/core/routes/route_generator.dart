import 'package:flutter/material.dart';
import 'app_routes.dart';

/// Builds routes from [AppRoutes.routes] with a shared fade-through + subtle
/// slide transition so navigation feels consistent across the app.
class RouteGenerator {
  const RouteGenerator._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = AppRoutes.routes[settings.name];

    if (builder == null) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => Scaffold(
          body: Center(child: Text('No route for ${settings.name}')),
        ),
      );
    }

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, _, _) => builder(context),
      transitionsBuilder: (context, animation, _, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
