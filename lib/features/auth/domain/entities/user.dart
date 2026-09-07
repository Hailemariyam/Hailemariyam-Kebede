import 'package:equatable/equatable.dart';

/// Domain representation of the signed-in M-PESA customer.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.balance,
    required this.currency,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final double balance;
  final String currency;

  @override
  List<Object?> get props =>
      [id, name, phoneNumber, email, balance, currency];
}
