import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mpesa_lehulum/core/error/failures.dart';
import 'package:mpesa_lehulum/features/auth/domain/entities/auth_session.dart';
import 'package:mpesa_lehulum/features/auth/domain/entities/user.dart';
import 'package:mpesa_lehulum/features/auth/domain/repositories/auth_repository.dart';
import 'package:mpesa_lehulum/features/auth/domain/usecases/login_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LoginUseCase useCase;

  const session = AuthSession(
    user: User(
      id: 'USR-10001',
      name: 'John Doe',
      phoneNumber: '251911234567',
      email: 'john.doe@example.com',
      balance: 1250.5,
      currency: 'ETB',
    ),
    token: 'mock_access_token_123456',
    expiresIn: 3600,
  );

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test('returns ValidationFailure and does NOT hit the repository for a bad PIN',
      () async {
    final result = await useCase(const LoginParams(pin: '12'));

    expect(result, isA<Left<Failure, AuthSession>>());
    result.fold(
      (l) => expect(l, isA<ValidationFailure>()),
      (_) => fail('expected a failure'),
    );
    verifyNever(() => repository.login(pin: any(named: 'pin')));
  });

  test('delegates to the repository for a valid PIN', () async {
    when(() => repository.login(pin: '1111'))
        .thenAnswer((_) async => const Right(session));

    final result = await useCase(const LoginParams(pin: '1111'));

    expect(result, const Right<Failure, AuthSession>(session));
    verify(() => repository.login(pin: '1111')).called(1);
  });

  test('propagates a repository failure unchanged', () async {
    when(() => repository.login(pin: '1111'))
        .thenAnswer((_) async => const Left(ServerFailure('User not found')));

    final result = await useCase(const LoginParams(pin: '1111'));

    result.fold(
      (l) => expect(l, const ServerFailure('User not found')),
      (_) => fail('expected a failure'),
    );
  });
}
