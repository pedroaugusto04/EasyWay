import 'dart:convert';

import 'package:http/http.dart' as http;

class LoginService {

  static Future<void> login(String email, String password) async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/login');

      final body = json.encode({
        'email': email,
        'password': password,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Login realizado com sucesso!');
      } else {
        print('Falha ao realizar login: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao realizar login: $e');
    }
  }
}
