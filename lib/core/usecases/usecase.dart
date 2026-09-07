import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Contract every use case implements: take [Params], return either a
/// [Failure] or a value of type [T].
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Marker for use cases that take no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
