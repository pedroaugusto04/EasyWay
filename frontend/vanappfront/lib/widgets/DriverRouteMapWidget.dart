import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/RouteModel.dart';
import '../models/UserModel.dart';
import '../providers/RouteLocationProvider.dart';
import '../services/WebSocketService.dart';

class DriverRouteMapWidget extends StatefulWidget {
  final RouteModel route;

  DriverRouteMapWidget({super.key, required this.route});

  @override
  _DriverRouteMapWidgetState createState() => _DriverRouteMapWidgetState();
}

class _DriverRouteMapWidgetState extends State<DriverRouteMapWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startTracking() async {

    final locationProvider = Provider.of<RouteLocationProvider>(context,listen: false);

    // Verifica as permissões antes de iniciar o rastreamento
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      print('Permissão de localização negada.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não é possível iniciar a rota sem a permissão de localização do motorista'),
        ),
      );
      return;
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      // carrega os passageiros
      List<UserModel> passengersToNotify = widget.route.passengers;
      locationProvider.setCurrentPassengers(passengersToNotify);

      locationProvider.startTracking(widget.route.id,context);
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permissão de localização negada permanentemente.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('É necessário permitir o acesso à localização nas configurações do dispositivo.'),
        ),
      );
    }
  }

  void _stopTracking() {
    final locationProvider = Provider.of<RouteLocationProvider>(context, listen: false);
    locationProvider.stopTracking();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<RouteLocationProvider>(context);
    final currentPosition = locationProvider.currentPosition;

    if (locationProvider.passengersToNotify.isEmpty && widget.route.passengers.isEmpty) {
      return Center(
        child: Text(
          'Nenhum passageiro para exibir no mapa.',
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      );
    }

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          minZoom: 11.0,
          maxZoom: 17.0,
          initialCenter: LatLng(
            widget.route.passengers.isNotEmpty
                ? widget.route.passengers[0].lat
                : 0.0,
            widget.route.passengers.isNotEmpty
                ? widget.route.passengers[0].lng
                : 0.0,
          ),
          interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          /* verifica primeiro se a rota esta em andamento
          caso esteja, devem ser exibidos os passageiros com as caracteristicas da rota em
          andamento
          Caso nao esteja, a rota nao esta ativa, exibe os passageiros a partir da rota
          carregada do banco
           */
          MarkerLayer(
            markers: locationProvider.isTracking
                ? locationProvider.passengersToNotify.map((passenger) {
              return Marker(
                point: LatLng(passenger.lat, passenger.lng),
                width: 500,
                height: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        IconButton( // notificações do passageiro
                          icon: Icon(
                            passenger.notificate
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: passenger.notificate
                                ? Colors.redAccent
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              passenger.notificate = !passenger.notificate;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  passenger.notificate
                                      ? 'Notificações ativadas para ${passenger.name}.'
                                      : 'Notificações desativadas para ${passenger.name}.',
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            passenger.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
                : widget.route.passengers.isNotEmpty
                ? widget.route.passengers.map((passenger) {
              return Marker(
                point: LatLng(passenger.lat, passenger.lng),
                width: 500,
                height: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        IconButton( // notificações do passageiro
                          icon: Icon(
                            passenger.notificate
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: passenger.notificate
                                ? Colors.redAccent
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              passenger.notificate = !passenger.notificate;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  passenger.notificate
                                      ? 'Notificações ativadas para ${passenger.name}.'
                                      : 'Notificações desativadas para ${passenger.name}.',
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            passenger.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
                : [],
          ),
          if (currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(currentPosition.latitude, currentPosition.longitude),
                  width: 500,
                  height: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.location_on,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              "Você está aqui",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Exibe o modal de confirmação antes de iniciar/parar o rastreamento
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(locationProvider.isTracking ? 'Parar rastreamento?' : 'Iniciar rastreamento?'),
                content: Text(
                  locationProvider.isTracking
                      ? 'Você tem certeza que deseja parar o rastreamento e finalizar a rota?'
                      : 'Você tem certeza que deseja iniciar o rastreamento da rota?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o modal
                    },
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o modal

                      // Ação de iniciar ou parar o rastreamento
                      if (locationProvider.isTracking) {
                        _stopTracking();
                      } else {
                        _startTracking();
                      }
                    },
                    child: Text('Confirmar'),
                  ),
                ],
              );
            },
          );
        },
        tooltip: locationProvider.isTracking ? 'Finalizar Rota' : 'Iniciar Rota',
        label: Text(
          locationProvider.isTracking ? 'Finalizar Rota' : 'Iniciar Rota',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(locationProvider.isTracking ? Icons.stop : Icons.directions),
        backgroundColor: locationProvider.isTracking ? Colors.red : null,
      ),
    );
  }
}
