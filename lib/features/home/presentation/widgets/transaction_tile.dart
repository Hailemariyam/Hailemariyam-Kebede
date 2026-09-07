import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';

/// One row in the transactions list: a coloured channel badge (e.g. CBE,
/// M-PESA), the counterparty name + channel, and the signed amount.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.isLast = false,
  });

  final TransactionEntity transaction;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final incoming = transaction.isIncoming;
    final amount =
        '${incoming ? '+' : '-'} ${Formatters.money(transaction.amount)}';

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          _ChannelBadge(label: transaction.channel),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: incoming ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelBadge extends StatelessWidget {
  const _ChannelBadge({required this.label});

  final String label;

  Color get _color {
    switch (label.toUpperCase()) {
      case 'CBE':
        return const Color(0xFF6A1B9A);
      case 'M-PESA':
      case 'MPESA':
        return AppColors.primary;
      case 'TELEBIRR':
        return const Color(0xFF1565C0);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        label.length <= 5 ? label : label.substring(0, 5),
        style: TextStyle(
          fontSize: label.length <= 3 ? 12 : 9,
          fontWeight: FontWeight.w800,
          color: _color,
        ),
      ),
    );
  }
}
