import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../models/UserModel.dart';
import '../providers/network/NetworkManagerProvider.dart';

class UserMapScreen extends StatefulWidget {
  final UserModel user;

  const UserMapScreen({super.key, required this.user});

  @override
  _UserMapScreenState createState() => _UserMapScreenState();
}

class _UserMapScreenState extends State<UserMapScreen> {
  String address = '';

  @override
  void initState() {
    super.initState();
    _getAddress();
  }

  Future<void> _getAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.user.lat,
        widget.user.lng,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          address = '${placemarks[0].street}${placemarks[0].locality}, ${placemarks[0].country}';
        });
      }
    } catch (e) {
      setState(() {
        address = 'Descrição do endereço não encontrada';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkManagerProvider = Provider.of<NetworkManagerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Endereço de: ${widget.user.name}'),
      ),
      body: networkManagerProvider.connectivityStatus == ConnectivityResult.none ?
      Center(child: Text("Sem conexão com a internet")) : Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              minZoom: 10.0,
              maxZoom: 17.0,
              initialCenter: LatLng(widget.user.lat, widget.user.lng),
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
                markers: [
                  Marker(
                    point: LatLng(widget.user.lat, widget.user.lng),
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
                                  address.isNotEmpty ? address : 'Carregando endereço...',
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
        ],
      ),
    );
  }
}
