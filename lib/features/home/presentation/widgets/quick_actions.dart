import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_colors.dart';

/// 4×2 grid of primary money actions.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.currency});

  final String currency;

  static const _items = <_Action>[
    _Action(Iconsax.send_2, 'Send Money'),
    _Action(Iconsax.money_recive, 'Withdraw'),
    _Action(Iconsax.mobile, 'Buy Airtime'),
    _Action(Iconsax.receipt_item, 'Pay Bill'),
    _Action(Iconsax.shop, 'Buy Goods'),
    _Action(Iconsax.people, 'Group Pay'),
    _Action(Iconsax.wallet_money, 'Loans & Save'),
    _Action(Iconsax.category, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 18,
        childAspectRatio: 0.82,
        children: [
          for (final a in _items) _QuickActionButton(action: a),
        ],
      ),
    );
  }
}

class _Action {
  const _Action(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action});

  final _Action action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(action.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
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
