import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:async';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized'])
      : super(message, statusCode: 401);
}

class ValidationException extends ApiException {
  ValidationException([String message = 'Validation failed'])
      : super(message, statusCode: 422);
}

class ServerException extends ApiException {
  ServerException([String message = 'Server error'])
      : super(message, statusCode: 500);
}

class ConnectionException extends ApiException {
  ConnectionException([String message = AppConfig.connectionErrorMessage])
      : super(message, statusCode: -1);
}

class ApiService {
  final String baseUrl;
  final Duration timeout;
  final _prefs = SharedPreferences.getInstance();

  ApiService({
    String? baseUrl,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        timeout = timeout ??
            const Duration(seconds: AppConfig.generalTimeoutSeconds) {
    developer.log('ApiService initialized with baseUrl: ${this.baseUrl}',
        name: 'ApiService');
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConfig.authTokenKey);
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    developer.log('Request headers: ${json.encode(headers)}',
        name: 'ApiService');
    return headers;
  }

  Future<T> _retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    DateTime startTime = DateTime.now();

    while (attempts < AppConfig.maxRetryAttempts) {
      try {
        // Log attempt information
        developer.log('Attempt ${attempts + 1}/${AppConfig.maxRetryAttempts}',
            name: 'ApiService');

        final result = await operation();

        // Log successful response time
        final duration = DateTime.now().difference(startTime);
        developer.log('Request completed in ${duration.inMilliseconds}ms',
            name: 'ApiService');

        return result;
      } catch (e) {
        attempts++;

        if (e is IOException || e is TimeoutException) {
          if (attempts >= AppConfig.maxRetryAttempts) {
            developer.log('Max retry attempts reached',
                name: 'ApiService',
                error: e is TimeoutException ? 'Timeout' : 'IO Error');

            if (e is TimeoutException) {
              throw ConnectionException(AppConfig.timeoutErrorMessage);
            }
            throw ConnectionException(
                '${AppConfig.connectionErrorMessage} (${e.toString()})');
          }

          // Calculate delay with exponential backoff
          final delay = AppConfig.retryDelayMilliseconds * attempts;

          // Log retry attempt with more details
          developer.log(
              'Network error on attempt $attempts/${AppConfig.maxRetryAttempts}\n'
              'Error type: ${e.runtimeType}\n'
              'Retrying in ${delay}ms\n'
              'URL: $baseUrl',
              name: 'ApiService',
              error: e);

          await Future.delayed(Duration(milliseconds: delay));
          continue;
        }

        // Log non-retryable error with more context
        developer.log(
            'Non-retryable error occurred\n'
            'Error type: ${e.runtimeType}\n'
            'Attempt: $attempts/${AppConfig.maxRetryAttempts}',
            name: 'ApiService',
            error: e);
        rethrow;
      }
    }

    // This should never be reached due to the throw in the loop above
    throw ConnectionException(AppConfig.networkErrorMessage);
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    developer.log(
      'API Response: Status ${response.statusCode}\n'
      'URL: ${response.request?.url}\n'
      'Headers: ${response.headers}\n'
      'Body: ${response.body}',
      name: 'ApiService',
    );

    // Handle empty responses (like 204 No Content)
    if (response.body.isEmpty) {
      if (response.statusCode == 204) {
        return null; // This is a valid case for DELETE operations
      }
      developer.log('Empty response body received', name: 'ApiService');
      throw ApiException('Empty response received from server');
    }

    dynamic body;
    try {
      body = json.decode(response.body);
    } catch (e) {
      developer.log('Failed to parse response body as JSON',
          name: 'ApiService', error: e);
      throw ApiException('Invalid response format from server');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return body;
      case 401:
        // Special handling for refresh token endpoint
        if (response.request != null &&
            response.request!.url.path.endsWith('/auth/refresh')) {
          final message =
              body is Map ? body['message'] ?? 'Unauthorized' : 'Unauthorized';
          throw UnauthorizedException(message);
        }
        final message =
            body is Map ? body['message'] ?? 'Unauthorized' : 'Unauthorized';
        throw UnauthorizedException(message);
      case 422:
        final message = body is Map
            ? body['message'] ?? 'Validation failed'
            : 'Validation failed';
        throw ValidationException(message);
      case 500:
        final message = body is Map
            ? body['message'] ?? AppConfig.serverErrorMessage
            : AppConfig.serverErrorMessage;
        throw ServerException(message);
      default:
        final message = body is Map
            ? body['message'] ?? AppConfig.networkErrorMessage
            : AppConfig.networkErrorMessage;
        throw ApiException(message, statusCode: response.statusCode);
    }
  }

  Future<bool> healthCheck() async {
    try {
      developer.log('Performing health check...', name: 'ApiService');
      final response =
          await http.get(Uri.parse('$baseUrl/health')).timeout(timeout);
      final isHealthy = response.statusCode == 200;
      developer.log(
          'Health check result: ${isHealthy ? 'Healthy' : 'Unhealthy'}',
          name: 'ApiService');
      return isHealthy;
    } catch (e) {
      developer.log('Health check failed: $e', name: 'ApiService');
      return false;
    }
  }

  Future<dynamic> get(String endpoint) async {
    return _retryOperation(() async {
      final headers = await getHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
          )
          .timeout(timeout);

      return _handleResponse(response);
    });
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    return _retryOperation(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await getHeaders();

      developer.log('POST request to: $uri', name: 'ApiService');
      final response = await http
          .post(uri, headers: headers, body: json.encode(data))
          .timeout(timeout);

      // Store token if it's in the response (for login/refresh endpoints)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData is Map && responseData['token'] != null) {
          final prefs = await _prefs;
          await prefs.setString(AppConfig.authTokenKey, responseData['token']);
          developer.log('Token stored in ApiService', name: 'ApiService');
        }
      }

      return _handleResponse(response);
    });
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    return _retryOperation(() async {
      final headers = await getHeaders();
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(timeout);

      return _handleResponse(response);
    });
  }

  Future<void> delete(String endpoint) async {
    return _retryOperation(() async {
      final headers = await getHeaders();
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
          )
          .timeout(timeout);

      // 204 No Content is a success response for DELETE
      if (response.statusCode == 204) {
        developer.log('Successfully deleted resource at $endpoint',
            name: 'ApiService');
        return;
      }

      if (response.statusCode != 200) {
        throw ApiException('Failed to delete resource: ${response.statusCode}');
      }

      return _handleResponse(response);
    });
  }
}
