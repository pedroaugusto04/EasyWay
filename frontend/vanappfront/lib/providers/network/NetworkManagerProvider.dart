import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkManagerProvider extends ChangeNotifier {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;

  ConnectivityResult get connectivityStatus => _connectivityStatus;

  set connectivityStatus(ConnectivityResult result) {
    _connectivityStatus = result;
    notifyListeners();
  }

  void startMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _connectivityStatus = result.first;
      notifyListeners();
    });
  }

  void stopMonitoring() {
    _connectivitySubscription?.cancel();
  }

  Future<void> checkInitialConnectivity() async {
    List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    _connectivityStatus = result.first;
    notifyListeners();
  }
}
