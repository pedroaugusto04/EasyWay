import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceTokenService {

  static Future<void> saveDeviceToken(String userId,
      String? deviceToken) async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/deviceToken');

      final body = json.encode({
        'userId': userId,
        'deviceToken': deviceToken,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
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
