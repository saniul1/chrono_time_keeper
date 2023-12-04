import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData getThemeData() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.bg.withOpacity(0.5),
      onBackground: AppColors.bg2.withOpacity(0.5),
      secondary: AppColors.accent,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
    ),
    scaffoldBackgroundColor: AppColors.bg.withOpacity(0.5),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.text,
      ),
      bodySmall: TextStyle(color: AppColors.text),
    ),
    sliderTheme: const SliderThemeData(),
  );
}
