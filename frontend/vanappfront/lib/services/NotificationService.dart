import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../exceptions/AuthenticationException.dart';
import '../models/UserModel.dart';
import 'LoginService.dart';
import 'UserService.dart';

class NotificationService {

  static Future<void> sendNotification(UserModel passenger) async {
    if (!passenger.notificate) {
      print("A notificacao para o passageiro: ${passenger.name} esta desabilitada");
      return;
    }
    String?  deviceToken = await UserService.getUserDeviceToken(passenger);
    final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

    if (deviceToken == null){
      print("Celular do usuário não cadastrado. Não é possível enviar notificação");
      return;
    }
    try {
      final apiUrl = dotenv.env['API_URL'];
      final url = Uri.parse('$apiUrl/notification/$deviceToken');

      String? jwtToken = await _secureStorage.read(key: "jwtToken");

      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken,
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
