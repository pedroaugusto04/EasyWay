import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vanappfront/services/NotificationService.dart';
import '../models/UserModel.dart';

class ProximityHelper {
  static void checkProximity(Position position, {
    required List<UserModel> passengers,
    double proximityThreshold = 3000, // distância em metros
  }) {

    final Distance distance = Distance();
    LatLng driverLatLng = LatLng(position.latitude, position.longitude);

    for (final passenger in passengers) {
      if (!passenger.notificate) continue; // nao precisa processar o passageiro se nao precisa enviar notificacao

      final double distanceToPassenger = distance.as(
        LengthUnit.Meter,
        driverLatLng,
        LatLng(passenger.lat, passenger.lng),
      );

      if (distanceToPassenger <= proximityThreshold) {
        NotificationService.sendNotification(passenger);
        passenger.notificate = false;
      }
    }
  }
}
