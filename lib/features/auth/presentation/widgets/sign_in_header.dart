import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

/// Brand-red header block with rounded bottom corners, overlaid with the
/// decorative pattern background: the M-PESA wordmark, a "Welcome back" line,
/// and a name / phone row fronted by a real avatar image.
class SignInHeader extends StatelessWidget {
  const SignInHeader({
    super.key,
    required this.name,
    required this.phoneNumber,
    this.avatarUrl = _defaultAvatarUrl,
  });

  static const String _defaultAvatarUrl =
      'https://i.pravatar.cc/160?img=68';

  final String name;
  final String phoneNumber;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            // Decorative pattern, anchored to the top-right, kept subtle.
            Positioned.fill(
              child: Opacity(
                opacity: 0.18,
                child: Image.asset(
                  AppAssets.patternBackground,
                  fit: BoxFit.cover,
                  alignment: Alignment.topRight,
                  colorBlendMode: BlendMode.screen,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, topInset + 28, 24, 28),
              child: Column(
                children: [
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    AppStrings.welcomeBack,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Avatar(
                        fallbackInitials: Formatters.initials(name),
                        url: avatarUrl,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.phone(phoneNumber),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small circular network avatar with a graceful loading and error fallback.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.fallbackInitials});

  static const double _size = 34;

  final String url;
  final String fallbackInitials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stack) => Center(
          child: Text(
            fallbackInitials,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
