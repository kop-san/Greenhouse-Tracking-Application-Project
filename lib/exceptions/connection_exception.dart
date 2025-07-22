class ConnectionException implements Exception {
  final String message;
  final int statusCode;

  ConnectionException([this.message = 'Unable to connect to server. Please check your internet connection and try again.'])
      : statusCode = -1;

  @override
  String toString() => message;
} 