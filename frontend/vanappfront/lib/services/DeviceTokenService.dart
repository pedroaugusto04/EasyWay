import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

      final apiUrl = dotenv.env['API_URL'];
      final url = Uri.parse('$apiUrl/deviceToken');

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
