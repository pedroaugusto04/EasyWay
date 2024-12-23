import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Exceptions/AuthenticationException.dart';
import 'LoginService.dart';

class DeviceTokenService {

  static Future<void> saveDeviceToken(String? jwtToken, String? deviceToken) async {
    try {
      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }
      if (deviceToken == null) {
        throw ArgumentError('deviceToken não pode ser nulo');
      }

      final url = Uri.parse('http://192.168.1.10:3000/deviceToken');

      final body = json.encode({
        'deviceToken': deviceToken,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Token salvo com sucesso!');
      } else {
        print('Falha ao salvar token: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao salvar token: $e');
    }
  }
}
