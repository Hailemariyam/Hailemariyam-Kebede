import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mpesa_lehulum/core/error/exceptions.dart';
import 'package:mpesa_lehulum/core/error/failures.dart';
import 'package:mpesa_lehulum/core/network/network_info.dart';
import 'package:mpesa_lehulum/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mpesa_lehulum/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mpesa_lehulum/features/auth/data/models/auth_session_model.dart';
import 'package:mpesa_lehulum/features/auth/data/models/user_model.dart';
import 'package:mpesa_lehulum/features/auth/data/repositories/auth_repository_impl.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockLocal extends Mock implements AuthLocalDataSource {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockNetworkInfo network;
  late AuthRepositoryImpl repository;

  final sessionModel = AuthSessionModel(
    user: const UserModel(
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
    registerFallbackValue(
      AuthSessionModel(
        user: const UserModel(
          id: '',
          name: '',
          phoneNumber: '',
          email: '',
          balance: 0,
          currency: '',
        ),
        token: '',
        expiresIn: 0,
      ),
    );
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    network = _MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: network,
    );
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(() => local.cacheSession(any())).thenReturn(null);
  });

  test('returns NetworkFailure when offline and never calls remote', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);

    final result = await repository.login(pin: '1111');

    expect(result, isA<Left<Failure, dynamic>>());
    result.fold((l) => expect(l, isA<NetworkFailure>()), (_) => fail('!'));
    verifyNever(() => remote.login(pin: any(named: 'pin')));
  });

  test('caches and returns the session on success', () async {
    when(() => remote.login(pin: '1111'))
        .thenAnswer((_) async => sessionModel);

    final result = await repository.login(pin: '1111');

    expect(result, Right<Failure, dynamic>(sessionModel));
    verify(() => local.cacheSession(sessionModel)).called(1);
  });

  test('maps ServerException to ServerFailure with its code', () async {
    when(() => remote.login(pin: '0000')).thenThrow(
      const ServerException('User not found', code: 'USER_NOT_FOUND'),
    );

    final result = await repository.login(pin: '0000');

    result.fold(
      (l) {
        expect(l, isA<ServerFailure>());
        expect(l.message, 'User not found');
        expect(l.code, 'USER_NOT_FOUND');
      },
      (_) => fail('expected a failure'),
    );
    verifyNever(() => local.cacheSession(any()));
  });

  test('maps ParsingException to ParsingFailure', () async {
    when(() => remote.login(pin: '1111'))
        .thenThrow(const ParsingException());

    final result = await repository.login(pin: '1111');

    result.fold((l) => expect(l, isA<ParsingFailure>()), (_) => fail('!'));
  });
}
