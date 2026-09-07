import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Validates the PIN, then delegates to [AuthRepository.login].
///
/// Validation lives here (not only in the widget) so the business rule is
/// enforced regardless of caller and is covered by domain unit tests.
class LoginUseCase implements UseCase<AuthSession, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSession>> call(LoginParams params) async {
    final validationError = Validators.pin(params.pin);
    if (validationError != null) {
      return Left(ValidationFailure(validationError));
    }
    return _repository.login(pin: params.pin);
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.pin});

  final String pin;

  @override
  List<Object?> get props => [pin];
}
