import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../helpers/ProximityHelper.dart';
import '../models/UserModel.dart';

class RouteLocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
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

  set isTracking(bool isTracking){
    isTracking = isTracking;
  }

  void startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return;
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      // inicia o estado de rastreamento
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
        ),
      ).listen((Position position) {
        _currentPosition = position;
        ProximityHelper.checkProximity(position,passengers: passengersToNotify);
        notifyListeners(); // Notifica os ouvintes para atualizar a UI
      });

      _isTracking = true;
      notifyListeners(); // notifica para atualizar a UI
    }
  }

  void stopTracking() {
    // finalizacao da rota
    _positionStreamSubscription?.cancel();
    currentPosition = null;
    _isTracking = false;
    passengersToNotify = [];
    notifyListeners(); // notifica para atualizar a UI
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
