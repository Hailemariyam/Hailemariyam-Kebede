import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Bridges domain and data: runs the remote call, caches the result, and maps
/// the datasource exception taxonomy onto [Failure]s.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, AuthSession>> login({required String pin}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final session = await _remote.login(pin: pin);
      _local.cacheSession(session);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  AuthSession? get currentSession => _local.session;

  @override
  Future<void> logout() async => _local.clear();
}
