import 'package:equatable/equatable.dart';

enum TransactionType { sent, received }

/// A single line item in the recent-activity list.
class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;

  bool get isIncoming => type == TransactionType.received;

  @override
  List<Object?> get props => [id, title, subtitle, amount, type];
}
