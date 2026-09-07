import '../models/auth_session_model.dart';

/// In-memory session cache for the lifetime of the app process.
///
/// Kept as an interface so it can later be swapped for a secure persistent
/// store (e.g. flutter_secure_storage) without touching the repository.
abstract class AuthLocalDataSource {
  AuthSessionModel? get session;
  void cacheSession(AuthSessionModel session);
  void clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthSessionModel? _session;

  @override
  AuthSessionModel? get session => _session;

  @override
  void cacheSession(AuthSessionModel session) => _session = session;

  @override
  void clear() => _session = null;
}
