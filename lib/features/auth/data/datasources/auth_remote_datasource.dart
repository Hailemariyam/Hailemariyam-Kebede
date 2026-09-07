import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_session_model.dart';

/// Talks to the login endpoint. Throws [ServerException] / [NetworkException] /
/// [ParsingException] (from [ApiClient]) — never returns error state.
abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({required String pin});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<AuthSessionModel> login({required String pin}) async {
    final json = await _client.postJson(
      ApiConstants.login,
      body: {'pin': pin},
    );
    return AuthSessionModel.fromResponse(json);
  }
}
