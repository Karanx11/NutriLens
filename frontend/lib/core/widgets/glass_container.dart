import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

/// A frosted-glass panel — a blurred, translucent surface used for overlays
/// and highlight cards.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double radius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.m),
    this.blur = 14,
    this.radius = AppSizes.radiusLg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = (isDark ? Colors.white : Colors.white).withValues(
      alpha: isDark ? 0.08 : 0.55,
    );
    final borderColor = Colors.white.withValues(alpha: isDark ? 0.12 : 0.6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}
