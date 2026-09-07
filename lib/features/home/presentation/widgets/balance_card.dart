import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/domain/entities/user.dart';

/// Primary-red wallet card: Main Balance with an "+ Add Money" black pill
/// button in the top-right corner, a Reward / Exit balance row, and a
/// hide/reveal eye toggle anchored to the bottom-right corner.
class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.user,
    this.onAddMoney,
  });

  final User user;
  final VoidCallback? onAddMoney;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _hidden = true;

  String get _currency => widget.user.currency;

  @override
  Widget build(BuildContext context) {
    final mainBalance =
        _hidden ? AppStrings.hiddenAmount : Formatters.money(widget.user.balance);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  AppStrings.mainBalance,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _AddMoneyButton(onTap: widget.onAddMoney),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _hidden ? mainBalance : '$_currency $mainBalance',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _SubBalance(
                  label: AppStrings.rewardBalance,
                  value: _hidden ? AppStrings.hiddenShort : '$_currency 250',
                ),
              ),
              Expanded(
                child: _SubBalance(
                  label: AppStrings.exitBalance,
                  value: _hidden ? AppStrings.hiddenShort : '$_currency 0',
                ),
              ),
              // Hide / reveal toggle, anchored to the bottom-right of the card.
              InkWell(
                onTap: () => setState(() => _hidden = !_hidden),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _hidden ? Iconsax.eye_slash : Iconsax.eye,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddMoneyButton extends StatelessWidget {
  const _AddMoneyButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.add, size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text(
                AppStrings.addMoney,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubBalance extends StatelessWidget {
  const _SubBalance({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
