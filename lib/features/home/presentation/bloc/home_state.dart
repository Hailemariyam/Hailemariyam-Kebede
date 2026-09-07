part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  final HomeStatus status;
  final List<TransactionEntity> transactions;
  final String? errorMessage;

  bool get isLoading => status == HomeStatus.loading;

  HomeState copyWith({
    HomeStatus? status,
    List<TransactionEntity>? transactions,
    String? Function()? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}
