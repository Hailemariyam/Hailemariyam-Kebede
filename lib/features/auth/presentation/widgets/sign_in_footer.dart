import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// One-row footer of tappable links: Forgot PIN (brand red) · Contact us
/// (with a headset icon) · Terms & Conditions (with a document icon).
class SignInFooter extends StatelessWidget {
  const SignInFooter({
    super.key,
    this.onForgotPin,
    this.onContactUs,
    this.onTerms,
  });

  final VoidCallback? onForgotPin;
  final VoidCallback? onContactUs;
  final VoidCallback? onTerms;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _link(AppStrings.forgotPin, onForgotPin, color: AppColors.primary),
        _dot(),
        _link(
          AppStrings.contactUs,
          onContactUs,
          trailingIcon: Iconsax.document_text,
        ),
        _dot(),
        _link(
          AppStrings.termsAndConditions,
          onTerms,
          trailingIcon: Iconsax.headphone,
        ),
      ],
    );
  }

  Widget _dot() => Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      );

  Widget _link(
    String label,
    VoidCallback? onTap, {
    Color? color,
    IconData? trailingIcon,
  }) {
    final tint = color ?? AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tint,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              Icon(trailingIcon, size: 13, color: tint),
            ],
          ],
        ),
      ),
    );
  }
}
