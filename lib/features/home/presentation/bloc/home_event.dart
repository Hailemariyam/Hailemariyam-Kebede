part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the dashboard feed.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Pull-to-refresh of the feed.
class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}
