import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../helpers/ProximityHelper.dart';
import '../models/UserModel.dart';
import '../services/WebSocketService.dart';

class RouteLocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
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

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return;
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      // inicia o estado de rastreamento
      _isTracking = true;
      _webSocketService.connectDriverToRoute(routeId);
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
        ),
      ).listen((Position position) {
        _currentPosition = position;
        _webSocketService.sendPosition(_currentPosition!);
        ProximityHelper.checkProximity(position,passengers: passengersToNotify);
        notifyListeners(); // Notifica os ouvintes para atualizar a UI
      });
    }
  }

  void stopTracking() {
    // finalizacao da rota
    _positionSubscription?.cancel();
    _webSocketService.stopSendingMessages();
    _webSocketService.closeConnection();
    currentPosition = null;
    _isTracking = false;
    passengersToNotify = [];
    notifyListeners(); // notifica para atualizar a UI
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
