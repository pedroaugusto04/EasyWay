import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {

  static Future<void> sendNotification(String? deviceToken) async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/notification/$deviceToken');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        }
      );

      if (response.statusCode == 200) {
        print('Notificação enviada com sucesso!');
      } else {
        print('Falha ao enviar notificação: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao enviar notificação: $e');
    }
  }
}
