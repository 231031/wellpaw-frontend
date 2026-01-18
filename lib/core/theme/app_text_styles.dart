import 'package:flutter/material.dart';
import 'app_colors.dart';

/// WellPaw Design System - Typography
class AppTextStyles {
  AppTextStyles._();

  // Headers
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Special Styles
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryBlue,
    decoration: TextDecoration.none,
    height: 1.4,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
    height: 1.5,
  );
}
