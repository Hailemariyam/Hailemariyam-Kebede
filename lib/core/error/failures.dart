import 'package:equatable/equatable.dart';

/// Base type for all recoverable errors surfaced to the domain / presentation
/// layers. Carries a user-facing [message] and an optional machine [code].
abstract class Failure extends Equatable {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// The server responded but rejected the request (non-2xx, or `success: false`).
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// The request could not reach the server (no connectivity, DNS, timeout).
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'No internet connection. Please check your network and try again.',
  ]);
}

/// The response was received but could not be parsed into the expected shape.
class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Received an unexpected response from the server.']);
}

/// Client-side input validation failed before any request was made.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Catch-all for anything unforeseen.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}
