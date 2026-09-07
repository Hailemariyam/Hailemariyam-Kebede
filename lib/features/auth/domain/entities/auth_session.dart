import 'package:equatable/equatable.dart';

import 'user.dart';

/// A successful authentication: the user plus their access token.
class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    required this.token,
    required this.expiresIn,
  });

  final User user;
  final String token;
  final int expiresIn;

  @override
  List<Object?> get props => [user, token, expiresIn];
}
