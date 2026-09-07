import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/home_repository.dart';

class GetRecentTransactions
    implements UseCase<List<TransactionEntity>, NoParams> {
  const GetRecentTransactions(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) {
    return _repository.getRecentTransactions();
  }
}
