class CepValidator {
  static bool isValidCep(String cep) {
    final cepPattern = RegExp(r'^[0-9]{8}$');
    return cepPattern.hasMatch(cep);
  }
}