import 'dart:async';
import 'package:flutter/cupertino.dart';
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

    _isTracking = true;
    _webSocketService.connectDriverToRoute(routeId);

    _location.changeSettings(
        accuracy: loc.LocationAccuracy.balanced,
        distanceFilter: 100 // atualiza de 100 em 100 metros
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
      _currentPosition = position;
      onUpdatePosition(position);
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
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100, // atualiza de 100 em 100 metros
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
    // desativa o rastreamento caso esteja rodando em background
    _positionBackgroundSubscription?.cancel();

    _webSocketService.stopSendingMessages();
    _webSocketService.closeConnection();
    currentPosition = null;
    _isTracking = false;
    passengersToNotify = [];
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