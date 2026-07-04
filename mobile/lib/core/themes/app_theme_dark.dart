import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gastromic/core/themes/app_colors.dart';

ThemeData appThemeDark() {
  final colorScheme = ColorScheme.dark(
    primary: AppColors.gold,
    secondary: AppColors.olive,
    error: AppColors.bordeaux,
    surface: AppColors.anthracite,
    onSurface: AppColors.cream,
    onPrimary: AppColors.anthracite,
  );

  final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.anthracite,
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
