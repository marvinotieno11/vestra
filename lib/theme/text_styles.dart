import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    color: AppColors.primary,
    fontSize: 42,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.secondary,
    fontSize: 20,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.secondary,
    fontSize: 16,
    height: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
}
