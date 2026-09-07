import '../../domain/entities/transaction.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.amount,
    required super.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: (json['type'] as String?) == 'received'
          ? TransactionType.received
          : TransactionType.sent,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'amount': amount,
        'type': type.name,
      };
}
