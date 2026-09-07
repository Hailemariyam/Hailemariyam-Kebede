import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_session.dart';

/// Domain-facing contract. The presentation layer depends only on this; the
/// concrete implementation lives in the data layer.
abstract class AuthRepository {
  /// Authenticate with a 4-digit [pin].
  Future<Either<Failure, AuthSession>> login({required String pin});

  /// Currently cached session, if the user is signed in.
  AuthSession? get currentSession;

  /// Clear the cached session.
  Future<void> logout();
}
