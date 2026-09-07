import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// White card holding the six service shortcuts in a 3×2 grid.
class ServicesCard extends StatelessWidget {
  const ServicesCard({super.key});

  static const _items = <_Service>[
    _Service(Iconsax.shop, AppStrings.merchantPayment),
    _Service(Iconsax.receipt_item, AppStrings.billPayment),
    _Service(Iconsax.wallet_money, AppStrings.creditAndSaving),
    _Service(Iconsax.send_2, AppStrings.transferMoney),
    _Service(Iconsax.mobile, AppStrings.airtimePackage),
    _Service(Iconsax.category, AppStrings.moreServices),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20,
        childAspectRatio: 0.88,
        children: [for (final s in _items) _ServiceButton(service: s)],
      ),
    );
  }
}

class _Service {
  const _Service(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _ServiceButton extends StatelessWidget {
  const _ServiceButton({required this.service});

  final _Service service;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(service.icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            service.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.2,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
