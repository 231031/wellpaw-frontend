import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 10,
          width: isActive ? 36 : 12,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : AppColors.dividerGray,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
