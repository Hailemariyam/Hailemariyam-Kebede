import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._local);

  final HomeLocalDataSource _local;

  @override
  Future<Either<Failure, List<TransactionEntity>>>
      getRecentTransactions() async {
    try {
      final txns = await _local.getRecentTransactions();
      return Right(txns);
    } catch (_) {
      return const Left(UnknownFailure('Could not load recent activity.'));
    }
  }
}
