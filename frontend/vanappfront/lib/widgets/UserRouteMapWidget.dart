import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/RouteModel.dart';
import '../providers/UserRouteLocationProvider.dart';
import '../services/WebSocketService.dart';

class UserRouteMapWidget extends StatefulWidget {
  final RouteModel route;
  bool isCameraAutoMove;

  UserRouteMapWidget({super.key, required this.route, required this.isCameraAutoMove});

  @override
  _UserRouteMapWidgetState createState() => _UserRouteMapWidgetState();
}

class _UserRouteMapWidgetState extends State<UserRouteMapWidget> {

  late WebSocketService _webSocketService;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService();
    _mapController = MapController();
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
  }

  void _moveCameraToPosition(Position position) {
    // 12 -> zoom apos movimentar
    _mapController.move(LatLng((position.latitude  ?? 0.0),
        position.longitude),12);
  }

  void _startTracking(BuildContext context) {
    final userLocationProvider = Provider.of<UserRouteLocationProvider>(context,listen: false);
    userLocationProvider.startTracking(widget.route.id,context);
  }

  void _stopTracking() {
    final userLocationProvider = Provider.of<UserRouteLocationProvider>(context,listen: false);

    userLocationProvider.stopTracking();
  }


  @override
  Widget build(BuildContext context) {
    final userLocationProvider = Provider.of<UserRouteLocationProvider>(context);
    final currentDriverPosition = userLocationProvider.currentDriverPosition;
    if (currentDriverPosition != null && widget.isCameraAutoMove){
      // ajusta a camera do mapa para centralizar no motorista
      _moveCameraToPosition(currentDriverPosition);
    }
    if (widget.route.passengers.isEmpty) {
      return Center(
        child: Text(
          'Nenhum passageiro para exibir no mapa.',
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      );
    }

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          minZoom: 10.0,
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
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: widget.route.passengers.map((passenger) {
              return Marker(
                point: LatLng(passenger.lat, passenger.lng),
                width: 500,
                height: 500,
                child: Center(
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
                ),
              );
            }).toList(),
          ),
          if (currentDriverPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(currentDriverPosition.latitude, currentDriverPosition.longitude),
                  width: 500,
                  height: 500,
                  child: Center(
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
                                "O motorista está aqui",
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
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(userLocationProvider.isTracking ? 'Parar rastreamento?' : 'Iniciar rastreamento?'),
                content: Text(
                  userLocationProvider.isTracking
                      ? 'Você tem certeza que deseja parar o rastreamento da rota?'
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
                    onPressed: () async {
                      Navigator.of(context).pop(); // Fecha o modal
                      if (userLocationProvider.isTracking) {
                          _stopTracking();
                      } else {
                         _startTracking(context);
                      }
                    },
                    child: Text('Confirmar'),
                  ),
                ],
              );
            },
          );
        },
        tooltip: userLocationProvider.isTracking ? 'Parar rastreamento' : 'Rastrear motorista',
        label: Text(
          userLocationProvider.isTracking ? 'Parar rastreamento' : 'Rastrear motorista',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(userLocationProvider.isTracking ? Icons.stop : Icons.gps_fixed),
        backgroundColor: userLocationProvider.isTracking ? Colors.red : null,
      ),
    );
  }

}
