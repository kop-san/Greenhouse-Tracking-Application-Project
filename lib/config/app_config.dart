import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  // Environment Configuration
  static bool get isProduction => dotenv.env['FLUTTER_ENV'] == 'production';
  static bool get isDebug => dotenv.env['DEBUG_LOGGING'] == 'true';
  static bool get isAndroidEmulator => dotenv.env['ANDROID_EMULATOR'] == 'true';

  // App Configuration
  static const String appName = 'Greenhouse Tracking App';
  static const String appVersion = '1.0.0';

  // Error Messages
  static const String connectionErrorMessage =
      'Unable to connect to server. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error occurred. Please try again later.';
  static const String networkErrorMessage =
      'Network error occurred. Please check your connection.';
  static const String timeoutErrorMessage =
      'The server is taking too long to respond. Please try again later.';

  // Timeout Configuration
  static const int loginTimeoutSeconds = 30;
  static const int logoutTimeoutSeconds = 5;
  static const int generalTimeoutSeconds = 30;
  static const int uploadTimeoutSeconds = 60;

  // Retry Configuration
  static const int maxRetryAttempts = 1;
  static const int retryDelayMilliseconds = 1000;

  // Validation Configuration
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String authTokenKey = 'auth_token';

  // Logging Configuration
  static bool get enableDebugLogging => dotenv.env['DEBUG_LOGGING'] == 'true';

  // Feature Flags
  static bool get enableTokenRefresh =>
      dotenv.env['ENABLE_TOKEN_REFRESH'] == 'true';
  static bool get enableRetry => dotenv.env['ENABLE_RETRY'] == 'true';
  static bool get enableOfflineMode =>
      dotenv.env['ENABLE_OFFLINE_MODE'] == 'true';
}
