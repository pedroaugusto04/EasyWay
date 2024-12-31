import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
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

  void startTracking(String routeId) async {
    _location = new loc.Location();

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled){
      serviceEnabled = await _location.requestService();
    }
    if (!serviceEnabled){
      return;
    }

    loc.PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied){
      permissionGranted = await _location.requestPermission();
    }
    if (permissionGranted != loc.PermissionStatus.granted) {
      return;
    }

    PermissionStatus backgroundPermission = await Permission.locationWhenInUse.request();

    if (backgroundPermission.isDenied) {
      backgroundPermission = await Permission.locationAlways.request();
    }

    if (backgroundPermission.isDenied) {
      /* caso nao tenha permissao para rodar em segundo plano,
      roda enquanto o aplicativo estiver aberto
       */
      runInForeground(routeId);
      return;
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
