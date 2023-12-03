import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData getThemeData() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.bg,
      onBackground: AppColors.bg2,
      secondary: AppColors.accent,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
    ),
    scaffoldBackgroundColor: AppColors.bg,
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
