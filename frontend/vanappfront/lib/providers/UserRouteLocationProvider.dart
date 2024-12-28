import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../main.dart';
import '../services/WebSocketService.dart';

class UserRouteLocationProvider extends ChangeNotifier {
  Position? _currentDriverPosition;
  StreamSubscription? _driverPositionSubscription;
  final WebSocketService _webSocketService = WebSocketService();
  bool _isTracking = false;
  bool _isDriverTracking = true;

  Position? get currentDriverPosition => _currentDriverPosition;
  bool get isTracking => _isTracking;
  bool get isDriverTracking => _isDriverTracking;

  set currentDriverPosition(Position? position) {
    _currentDriverPosition = position;
    notifyListeners();
  }

  void startTracking(String routeId, BuildContext context) {
    _webSocketService.connectToRoute(routeId);  // Espera a conexão ser estabelecida
    _isTracking = true;
    notifyListeners();
    _driverPositionSubscription = _webSocketService.channel!.stream.listen(
      (message) {
      print('Mensagem recebida pelo passageiro: $message');
      final data = jsonDecode(message);
      // Verifica se há erro na resposta
      if (data['error'] != null) {
        stopTracking(isDriverTracking: false);
        return;
      }

      // Atualiza a posição do motorista
      _currentDriverPosition = Position(
        latitude: data['latitude'],
        longitude: data['longitude'],
        timestamp: DateTime.now(),
        accuracy: data['accuracy'] ?? 0.0,
        altitude: data['altitude'] ?? 0.0,
        speed: data['speed'] ?? 0.0,
        heading: data['heading'] ?? 0.0, altitudeAccuracy: 0, headingAccuracy: 0,
        speedAccuracy: 0,
      );

      notifyListeners(); // Atualiza a UI com a nova posição
      },
      onError: (error) {
        print("Erro na conexão: $error");
      },
      onDone: () {
        print("Conexão fechada");
      },
    );
  }

   void stopTracking({bool isDriverTracking = true}) {
    _driverPositionSubscription?.cancel();
    _webSocketService.stopSendingMessages();
    _webSocketService.closeConnection();
    _isTracking = false;
    currentDriverPosition = null;
    _isDriverTracking = isDriverTracking;
    if (!isDriverTracking) {
      MyApp.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Não foi possível rastrear o motorista. A rota não está em andamento.')));
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _driverPositionSubscription?.cancel();
    super.dispose();
  }
}
