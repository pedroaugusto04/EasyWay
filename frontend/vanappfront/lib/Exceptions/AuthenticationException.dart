class AuthenticationException implements Exception {
  final String message;

  AuthenticationException([this.message = "A autenticacao falhou"]);

  @override
  String toString() => message;
}