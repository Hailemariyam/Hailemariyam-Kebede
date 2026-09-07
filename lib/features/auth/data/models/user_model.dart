import '../../domain/entities/user.dart';

/// Data-layer model: knows how to (de)serialise itself. Extends the domain
/// [User] so it can be passed straight up without a mapping step.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.email,
    required super.balance,
    required super.currency,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'balance': balance,
        'currency': currency,
      };
}
