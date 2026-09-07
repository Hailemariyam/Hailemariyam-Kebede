import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

/// The recent-activity feed. The API only exposes login, so this is served
/// from a local datasource today; the interface lets a real endpoint drop in
/// later without touching the BLoC or UI.
abstract class HomeRepository {
  Future<Either<Failure, List<TransactionEntity>>> getRecentTransactions();
}
