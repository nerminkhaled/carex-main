import 'package:flutter/material.dart';

class AppColors {
  static const teal = Color(0xFF1ABFB0);
  static const tealDark = Color(0xFF0BA89A);
  static const pinkRed = Color(0xFFE8556D);
  static const background = Color(0xFFF0FAFA);
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          primary: AppColors.teal,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
      );
}
