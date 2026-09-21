import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'theme_builder.dart';

class DarkTheme {
  const DarkTheme._();

  static ThemeData get theme => buildAppTheme(
        brightness: Brightness.dark,
        scaffoldBackground: AppColors.darkBackground,
        surface: AppColors.darkSurface,
      );
}
