import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

class WebSocketService {
  WebSocketChannel? channel;
  Timer? _timer;

  void connectDriverToRoute(String routeId)  {
      final apiUrlWebSocket = dotenv.env['API_URL_WEB_SOCKET'];
      final String url = 'ws://$apiUrlWebSocket/driver/$routeId';

      channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void connectToRoute(String routeId) {
    final apiUrlWebSocket = dotenv.env['API_URL_WEB_SOCKET'];
    final String url = 'ws://$apiUrlWebSocket/passenger/$routeId';

    try {
      channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      // Captura de erro ao tentar conectar
      print('Erro ao tentar conectar ao WebSocket: $e');
    }
  }

  void sendPosition(Position position) {
    final message = {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
    if (channel != null) {
      channel!.sink.add(json.encode(message));
    }
  }

  void stopSendingMessages() {
    _timer?.cancel();
    print('Envio de mensagens parado.');
  }

  void closeConnection() {
    if (channel != null) {
      channel!.sink.close();
      channel = null;
    }
  }
}
