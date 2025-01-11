import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:vanappfront/validators/CepValidator.dart';
import '../models/RegisterUserModel.dart';
import '../services/UserService.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cepController = TextEditingController();
  late final MapController _mapController;
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    // Verifica as permissões antes de recuperar o endereço do usuário
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Permissão de localização negada.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não é possível recuperar o endereço automaticamente sem a permissão de localização'),
        ),
      );
      return;
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      // Recupera a localização atual do usuário
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high
          )
        );
        setState(() {
          userLocation = position;
          _mapController.move(LatLng(userLocation!.latitude,
              userLocation!.longitude), 12);
        });
      } catch (e) {
        print('Erro ao obter localização: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao obter localização. Tente novamente.'),
          ),
        );
      }
    }
  }

  Future<void> register() async {
    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, defina uma localização no mapa'),
        ),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final user = RegisterUserModel(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        lat: userLocation!.latitude,
        lng: userLocation!.longitude,
      );

      try {
        bool isCreated = await UserService.createUser(user);
        if (isCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao registrar usuário. Verifique as informações digitadas.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao registrar usuário. Verifique as informações digitadas.')),
        );
      }
    }
  }

  Future<void> searchPositionByCEP() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');

    if (!CepValidator.isValidCep(cep)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O CEP inserido é inválido.'),
        ),
      );
      return;
    }

    final url = 'https://viacep.com.br/ws/$cep/json/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao buscar endereço por CEP."),
          ),
        );
        return;
      }

      final data = json.decode(response.body);

      if (data['erro'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("CEP não encontrado"),
          ),
        );
        return;
      }

      String street = data['logradouro'];
      String neighborhood = data['bairro'];
      String city = data['localidade'];
      String state = data['uf'];

      String address = "$street, $neighborhood, $city, $state, Brasil";

      List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Não foi possível recuperar a localização referente ao CEP"),
          ),
        );
        return;
      }

      Location location = locations.first;

      setState(() {
        userLocation = Position(
          longitude: location.longitude,
          latitude: location.latitude,
          timestamp: DateTime.now(),
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
          accuracy: 0,
        );
        _mapController.move(LatLng(location.latitude,
            location.longitude), 12);
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao buscar endereço por CEP."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Registro de Usuário"),
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu e-mail';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                minZoom: 0,
                                maxZoom: 20,
                                // -19,-42 coordenadas padrao, caso nao consiga recuperar do usuario
                                initialCenter: LatLng(
                                  userLocation?.latitude ?? -19,
                                  userLocation?.longitude ?? -42,
                                ),
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                                ),
                                initialZoom: 12.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                if (userLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(userLocation!.latitude,userLocation!.longitude),
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
                                                    "Endereço selecionado",
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
                            Positioned(
                              top: 16.0,
                              left: 16.0,
                              right: 16.0,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _cepController,
                                      decoration: InputDecoration(
                                        hintText: 'Digite seu CEP',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                        filled: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  ElevatedButton(
                                    onPressed: searchPositionByCEP,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          'Registrar',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Já tem uma conta? Faça login',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
