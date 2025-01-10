import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:vanappfront/widgets/BackgroundPermissionHelper.dart';
import '../helpers/ProximityHelper.dart';
import '../models/UserModel.dart';
import '../services/WebSocketService.dart';

class RouteLocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription? _driverPositionSubscription;
  StreamSubscription<Position>? _positionForegroundSubscription;
  StreamSubscription<loc.LocationData>? _positionBackgroundSubscription;
  late loc.Location _location;
  final WebSocketService _webSocketService = WebSocketService();
  bool _isTracking = false;
  List<UserModel> passengersToNotify = [];

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;

  void setCurrentPassengers(List<UserModel> passengers) {
    this.passengersToNotify = passengers;
  }
  set currentPosition(Position? position) {
    _currentPosition = position;
    notifyListeners();
  }

  void startTracking(String routeId,BuildContext context) async {
    _location = new loc.Location();

    PermissionStatus backgroundPermission = await Permission.locationAlways.request();

    if (!backgroundPermission.isGranted) {
      // caso o usuario tenha permitido apenas durante o uso do app, ainda deve ser possivel rastrear
      PermissionStatus permissionStatusInAppUse = await Permission.locationWhenInUse.status;
      if (permissionStatusInAppUse.isDenied) {
        // se ate a permissao durante o app for negada, nao pode rastrear
        return;
      } else {
        // alerta que pode apresentar problemas no rastreamento em segundo plano
        BackgroundPermissionHelper.show(context);
      }
    }

    _webSocketService.connectDriverToRoute(routeId); // inicia a rota a partir do motorista

    _isTracking = true;
    notifyListeners();

    _location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        //distanceFilter: 100 // atualiza de 100 em 100 metros
    );

    // ativa para rodar em segundo plano
    _location.enableBackgroundMode(enable: true);

    _location.changeNotificationOptions(
      title: 'GeoLocalização',
      subtitle: 'Sua localização está sendo transmitida',
    );

    _positionBackgroundSubscription = _location.onLocationChanged.listen((loc.LocationData currentLocation) {
      Position position = new Position(latitude: currentLocation.latitude!,
          longitude: currentLocation.longitude!,
          timestamp: DateTime.now(), accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0);
      /* a posicao do motorista eh atualizada diretamente, nao
      precisa esperar do web socket
       */
      _currentPosition = position;
      onUpdatePosition(position);
    });

    _driverPositionSubscription = _webSocketService.channel!.stream.listen(
          (message) {
        print('Mensagem recebida pelo passageiro: $message');
        _isTracking = true;
        final data = jsonDecode(message);
        // Verifica se há erro na resposta
        if (data['error'] != null) {
          stopTracking();
          return;
        }

        notifyListeners(); // Atualiza a UI com a nova posição
      },
      onError: (error) {
        print("Erro na conexão: $error");
      },
      onDone: () {
        print("Conexão fechada");
        stopTracking();
        _tryReconnectWebSocket(routeId,context);
      },
    );
  }


  void _tryReconnectWebSocket(String routeId, BuildContext context, {int attempt = 1}) {
    // tenta reconectar com intervalos progressivos
    // a cada conexao falha, aumenta o tempo em 5 segundos
    print("Tentando reconectar... (Tentativa $attempt)");
    Future.delayed(Duration(seconds: attempt * 10), () async {
      _webSocketService.connectDriverToRoute(routeId);
      if (_isTracking) return;

      startTracking(routeId,context);
      // nao conseguiu conectar, tenta novamente conforme o intervalo
      if (!_isTracking) _tryReconnectWebSocket(routeId,context,attempt: attempt + 1);
    });
  }

  void onUpdatePosition(Position position) {
    /* envia a posicao para os passageiros conectados e verifica
      a necessidade de enviar notificacoes
     */
    _webSocketService.sendPosition(_currentPosition!);
    ProximityHelper.checkProximity(position,passengers: passengersToNotify);
    notifyListeners(); // Notifica os ouvintes para atualizar a UI
  }

  void runInForeground(String routeId) async {
    // inicia rastreamento em primeiro plano
    _isTracking = true;
    _webSocketService.connectDriverToRoute(routeId);
    _positionForegroundSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        //distanceFilter: 100, // atualiza de 100 em 100 metros
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _webSocketService.sendPosition(_currentPosition!);
      ProximityHelper.checkProximity(position,passengers: passengersToNotify);
      notifyListeners(); // Notifica os ouvintes para atualizar a UI
    });
  }

  void stopTracking() {
    // finalizacao da rota

    // desativa o rastreamento caso esteja rodando em foreground
    _positionForegroundSubscription?.cancel();
    // desativa a recuperacao da localizacao caso esteja rodando em background
    _positionBackgroundSubscription?.cancel();
    // desativa o rastreamento caso esteja rodando em background
    _driverPositionSubscription?.cancel();

    _webSocketService.stopSendingMessages();
    _webSocketService.closeConnection();
    currentPosition = null;
    _isTracking = false;
    notifyListeners(); // notifica para atualizar a UI
  }

  @override
  void dispose() {
    // desativa o rastreamento caso esteja rodando em foreground
    _positionForegroundSubscription?.cancel();
    // desativa o rastreamento caso esteja rodando em background
    _positionBackgroundSubscription?.cancel();

    super.dispose();
  }
}