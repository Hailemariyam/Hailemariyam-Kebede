import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Four square boxes that fill as PIN digits are entered. Display-only — input
/// comes from the custom [NumberKeypad], not a system keyboard.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.filledCount,
    this.hasError = false,
  });

  final int length;
  final int filledCount;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final filled = i < filledCount;
        final borderColor = hasError
            ? AppColors.error
            : (filled ? AppColors.primary : AppColors.divider);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 54,
          height: 60,
          decoration: BoxDecoration(
            color: filled
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: filled || hasError ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: filled
              ? const Icon(Icons.circle, size: 14, color: AppColors.primary)
              : const SizedBox.shrink(),
        );
      }),
    );
  }
}
