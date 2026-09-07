import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_colors.dart';

/// Custom on-screen numeric keypad, white background, laid out as:
///
///   1 2 3
///   4 5 6
///   7 8 9
///     0 ⌫
class NumberKeypad extends StatelessWidget {
  const NumberKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(['1', '2', '3']),
          _row(['4', '5', '6']),
          _row(['7', '8', '9']),
          Row(
            children: [
              const Expanded(child: SizedBox(height: 64)),
              Expanded(child: _DigitKey(value: '0', onTap: _tapDigit)),
              Expanded(
                child: _ActionKey(
                  icon: Iconsax.close_circle,
                  onTap: enabled ? onBackspace : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(List<String> values) {
    return Row(
      children: [
        for (final v in values)
          Expanded(child: _DigitKey(value: v, onTap: _tapDigit)),
      ],
    );
  }

  void _tapDigit(String v) {
    if (enabled) onDigit(v);
  }
}

class _DigitKey extends StatelessWidget {
  const _DigitKey({required this.value, required this.onTap});

  final String value;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => onTap(value),
      radius: 40,
      child: SizedBox(
        height: 64,
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionKey extends StatelessWidget {
  const _ActionKey({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 40,
      child: SizedBox(
        height: 64,
        child: Center(
          child: Icon(
            icon,
            size: 26,
            color: onTap == null
                ? AppColors.textSecondary.withValues(alpha: 0.4)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
