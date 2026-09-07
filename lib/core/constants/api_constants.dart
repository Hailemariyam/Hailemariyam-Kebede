/// Endpoints and network configuration for the mock M-Pesa backend.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://api.mockfly.dev/mocks/5064738f-5131-4b0a-8909-ca1634e26c27';

  static const String login = '$baseUrl/login';

  static const Duration receiveTimeout = Duration(seconds: 20);

  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
