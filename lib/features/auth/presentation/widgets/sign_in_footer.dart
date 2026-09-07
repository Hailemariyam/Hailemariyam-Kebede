import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// One-row footer of tappable text links: Forgot PIN (brand red) · Contact us ·
/// Terms & Conditions.
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
        _link(AppStrings.contactUs, onContactUs),
        _dot(),
        _link(AppStrings.termsAndConditions, onTerms),
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

  Widget _link(String label, VoidCallback? onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
