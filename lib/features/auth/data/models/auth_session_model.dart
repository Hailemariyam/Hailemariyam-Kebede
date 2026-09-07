import '../../domain/entities/auth_session.dart';
import 'user_model.dart';

/// Parses the `data` object of a successful login response.
class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required UserModel super.user,
    required super.token,
    required super.expiresIn,
  });

  /// [json] is the full response body: `{ success, message, data: {...} }`.
  factory AuthSessionModel.fromResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return AuthSessionModel(
      user: UserModel.fromJson(
        data['user'] as Map<String, dynamic>? ?? const {},
      ),
      token: data['token'] as String? ?? '',
      expiresIn: (data['expiresIn'] as num?)?.toInt() ?? 0,
    );
  }
}
