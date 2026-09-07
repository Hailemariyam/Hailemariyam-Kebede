// Thrown by the data layer (datasources) and mapped to `Failure`s in the
// repository implementations. Presentation code never sees these directly.

class ServerException implements Exception {
  const ServerException(this.message, {this.code});
  final String message;
  final String? code;
}

class NetworkException implements Exception {
  const NetworkException([
    this.message =
        'Unable to connect. Please check your internet connection and try again.',
  ]);
  final String message;
}

class ParsingException implements Exception {
  const ParsingException([this.message = 'Failed to parse response']);
  final String message;
}
