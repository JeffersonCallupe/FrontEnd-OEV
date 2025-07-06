class ConnectionTimeout implements Exception {}

class InvalidToken implements Exception {}

class WrongCredentials implements Exception {}

class CustomError implements Exception {
  final String message;

  // final int errorCode;
  CustomError(this.message);
}

class NotAuthorizedException implements Exception {
  final String message;
  NotAuthorizedException(this.message);
  
  @override
  String toString() => message;
}