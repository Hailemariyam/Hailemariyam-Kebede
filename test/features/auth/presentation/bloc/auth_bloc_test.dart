import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mpesa_lehulum/core/error/failures.dart';
import 'package:mpesa_lehulum/core/usecases/usecase.dart';
import 'package:mpesa_lehulum/features/auth/domain/entities/auth_session.dart';
import 'package:mpesa_lehulum/features/auth/domain/entities/user.dart';
import 'package:mpesa_lehulum/features/auth/domain/usecases/login_usecase.dart';
import 'package:mpesa_lehulum/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mpesa_lehulum/features/auth/presentation/bloc/auth_bloc.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late _MockLoginUseCase login;
  late _MockLogoutUseCase logout;

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

  setUpAll(() {
    registerFallbackValue(const LoginParams(pin: ''));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    login = _MockLoginUseCase();
    logout = _MockLogoutUseCase();
  });

  AuthBloc build() =>
      AuthBloc(loginUseCase: login, logoutUseCase: logout);

  group('AuthPinChanged', () {
    blocTest<AuthBloc, AuthState>(
      'marks the PIN valid once 4 digits are entered, no inline error',
      build: build,
      act: (b) => b.add(const AuthPinChanged('1234')),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.isPinValid, 'isPinValid', true)
            .having((s) => s.pinError, 'pinError', isNull),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'does not show an inline error while the PIN is incomplete',
      build: build,
      act: (b) => b.add(const AuthPinChanged('12')),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.isPinValid, 'isPinValid', false)
            .having((s) => s.pinError, 'pinError', isNull),
      ],
    );
  });

  group('AuthLoginSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] and carries the session on success',
      build: build,
      setUp: () => when(() => login(any()))
          .thenAnswer((_) async => const Right(session)),
      seed: () => const AuthState(pin: '1111', isPinValid: true),
      act: (b) => b.add(const AuthLoginSubmitted()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.session, 'session', session),
      ],
      verify: (_) => verify(() => login(any())).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] with the failure message on error',
      build: build,
      setUp: () => when(() => login(any())).thenAnswer(
        (_) async => const Left(ServerFailure('User not found')),
      ),
      seed: () => const AuthState(pin: '0000', isPinValid: true),
      act: (b) => b.add(const AuthLoginSubmitted()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'User not found'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'short-circuits to failure without calling the use case for an invalid PIN',
      build: build,
      seed: () => const AuthState(pin: '12'),
      act: (b) => b.add(const AuthLoginSubmitted()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.failure),
      ],
      verify: (_) => verifyNever(() => login(any())),
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'clears state back to initial',
      build: build,
      setUp: () =>
          when(() => logout(any())).thenAnswer((_) async => const Right(null)),
      seed: () => const AuthState(
        status: AuthStatus.authenticated,
        pin: '1111',
        session: session,
      ),
      act: (b) => b.add(const AuthLogoutRequested()),
      expect: () => [const AuthState()],
    );
  });
}
