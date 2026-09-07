import 'dart:io';

/// Lightweight connectivity probe. A dedicated abstraction keeps the
/// repository testable (mock this) and avoids pulling a heavy plugin for a
/// single check. On web `InternetAddress.lookup` is unsupported, so we
/// optimistically assume connectivity and let the HTTP call surface failures.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('one.one.one.one')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      // Web / unsupported platform: don't block the request.
      return true;
    }
  }
}
