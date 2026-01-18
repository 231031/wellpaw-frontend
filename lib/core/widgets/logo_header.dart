import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';

/// WellPaw logo header component
class LogoHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const LogoHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(Icons.pets, size: 50, color: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 16),

          // App Name
          const Text(
            'WellPaw',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Tagline
          const Text(
            'Pet Nutrition & Health Care',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 24),

          // Page Title
          Text(title, style: AppTextStyles.h2.copyWith(color: AppColors.white)),
          const SizedBox(height: 8),

          // Subtitle
          Text(subtitle, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}
