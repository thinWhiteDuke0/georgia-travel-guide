/// Central runtime configuration.
///
/// Pass the gateway URL at run time:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
class AppConfig {
  /// Base URL of the API Gateway.
  /// 10.0.2.2 is the host machine's localhost as seen from the Android emulator.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
}
