import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'theme_builder.dart';

class LightTheme {
  const LightTheme._();

  static ThemeData get theme => buildAppTheme(
        brightness: Brightness.light,
        scaffoldBackground: AppColors.background,
        surface: AppColors.surface,
      );
}
