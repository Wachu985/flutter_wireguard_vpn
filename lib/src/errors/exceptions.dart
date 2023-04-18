class ConnectionException implements Exception {
  /// Constructor of the [ConnectionException] class that allows storing the error [message].
  const ConnectionException({required this.message});

  /// It stores the error [message].
  final String message;
}
