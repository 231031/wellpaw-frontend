import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// WellPaw Design System - Typography
class AppTextStyles {
  AppTextStyles._();

  // Headers
  static const TextStyle h1 = TextStyle(
    fontSize: AppTypography.headline,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: AppTypography.subheading,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: AppTypography.subheading,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: AppTypography.body,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: AppTypography.bodyCompact,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: AppTypography.caption,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Special Styles
  static const TextStyle subtitle = TextStyle(
    fontSize: AppTypography.bodyCompact,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: AppTypography.body,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: AppTypography.bodyCompact,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryBlue,
    decoration: TextDecoration.none,
    height: 1.4,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: AppTypography.bodyCompact,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: AppTypography.body,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: AppTypography.body,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
    height: 1.5,
  );
}
