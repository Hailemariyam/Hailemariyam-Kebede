import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_recent_transactions.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Loads the recent-activity feed for the home dashboard.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetRecentTransactions getRecentTransactions})
      : _getRecentTransactions = getRecentTransactions,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onStarted);
  }

  final GetRecentTransactions _getRecentTransactions;

  Future<void> _onStarted(HomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: () => null));
    final result = await _getRecentTransactions(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: () => failure.message,
      )),
      (txns) => emit(state.copyWith(
        status: HomeStatus.success,
        transactions: txns,
      )),
    );
  }
}
