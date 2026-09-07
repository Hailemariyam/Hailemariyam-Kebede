import 'package:equatable/equatable.dart';

enum TransactionType { sent, received }

/// A single line item in the transactions list.
class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.channel,
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;

  /// Payment channel shown as the badge label, e.g. "CBE", "M-PESA".
  final String channel;

  bool get isIncoming => type == TransactionType.received;

  @override
  List<Object?> get props => [id, title, subtitle, amount, type, channel];
}
