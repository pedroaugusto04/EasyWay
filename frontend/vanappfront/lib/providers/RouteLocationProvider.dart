import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class RouteLocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTracking = false;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;

  set currentPosition(Position? position) {
    _currentPosition = position;
    notifyListeners();
  }

  void startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      // Handle permission denied
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
        print(position);
        notifyListeners(); // Notifica os ouvintes para atualizar a UI
      });

      _isTracking = true;
      notifyListeners(); // notifica para atualizar a UI
    }
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _isTracking = false;  // finalizacao da rota
    notifyListeners(); // notifica para atualizar a UI
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
