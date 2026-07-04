import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gastromic/core/themes/app_colors.dart';

ThemeData appThemeLight() {
  final colorScheme = ColorScheme.light(
    primary: AppColors.gold,
    secondary: AppColors.olive,
    error: AppColors.bordeaux,
    surface: Colors.white,
    onSurface: AppColors.anthracite,
    onPrimary: AppColors.anthracite,
  );

  final baseTextTheme = GoogleFonts.interTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.cream,
    textTheme: baseTextTheme.copyWith(
      headlineLarge: GoogleFonts.manrope(
        textStyle: baseTextTheme.headlineLarge,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.manrope(
        textStyle: baseTextTheme.headlineMedium,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.manrope(
        textStyle: baseTextTheme.titleLarge,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
