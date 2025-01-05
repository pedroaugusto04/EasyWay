import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:vanappfront/services/UserService.dart';
import 'package:vanappfront/widgets/CustomAppBar.dart';
import '../models/RouteModel.dart';
import '../providers/RouteLocationProvider.dart';
import '../services/RoutesService.dart';
import '../widgets/DriverRouteMapWidget.dart';
import '../widgets/UserRouteMapWidget.dart';
import 'CreateRouteScreen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  late Future<List<RouteModel>> _routesFuture = Future.value([]);
  RouteModel? selectedRoute;
  bool isDriver = false;
  late Map<String, bool> mapRouteDriver = {};
  late bool isLoadFinished = false;
  bool isCameraAutoMove = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    loadRoutes();
    verificateDriver(); // verifica se o usuario eh motorista e se eh motorista de cada rota
  }

  Future<void> verificateDriver() async {
    await verifyDriver();
    verifyIsRoutesDriver();
  }

  Future<void> verifyDriver() async {
    // verifica se o usuario eh um motorista ativo
    bool userIsDriver = await UserService.verifyUserIsDriver();
    setState(() {
      isDriver = userIsDriver;
    });
  }

  Future<void> verifyIsRoutesDriver() async {
    // mapeia pelo id da rota se o usuario eh motorista ou nao
    List<RouteModel> routes = await _routesFuture;
    List<String> routesId = routes.map((route) => route.id).toList();
    Map<String,bool> mapResult = await UserService.verifyUserIsRoutesDriver(routesId,isDriver);
    setState(() {
      mapRouteDriver = mapResult;
      isLoadFinished = true; // somente deve exibir a pagina apos saber a relacao do usuario em cada rota
    });
  }

  Future<void> loadRoutes() async {
    _routesFuture = fetchRoutes();
  }

  Future<List<RouteModel>> fetchRoutes() async {
    return await RoutesService.getRoutes() ?? [];
  }

  Future<List<RouteModel>> fetchRoutesDrivenByUser() async {
    return await RoutesService.getRoutesDrivenByUser() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<RouteLocationProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          FutureBuilder<List<RouteModel>>(
            future: _routesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || !isLoadFinished) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Icon(Icons.error, color: Colors.red));
              } else if (snapshot.hasData) {
                final routes = snapshot.data!;
                if (selectedRoute == null && routes.isNotEmpty) {
                  // começa selecionando a primeira rota
                  selectedRoute = routes.first;
                }

                if (selectedRoute == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Você não possui rotas para exibir no mapa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isDriver)
                        ElevatedButton(
                          onPressed: () async {
                            final bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreateRouteScreen()),
                            );

                            if (result == true){
                              setState(() {
                                loadRoutes();
                                verificateDriver();
                              });
                            }

                          },
                          child: const Text(
                            'Criar uma rota',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (selectedRoute!.passengers.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum passageiro para exibir no mapa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                // renderiza o mapa com a nova rota
                return mapRouteDriver[selectedRoute?.id] ?? false ? DriverRouteMapWidget(key: ValueKey(selectedRoute!), route: selectedRoute!,
                isCameraAutoMove: isCameraAutoMove)
                    :
                UserRouteMapWidget(key: ValueKey(selectedRoute!), route: selectedRoute!, isCameraAutoMove: isCameraAutoMove);
              } else {
                return const SizedBox();
              }
            },
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: FutureBuilder<List<RouteModel>>(
              future: _routesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                } else if (snapshot.hasError) {
                  return const SizedBox();
                } else if (snapshot.hasData) {
                  final routes = snapshot.data!;
                  return Text(
                    selectedRoute != null
                        ? 'Rota: ${selectedRoute!.name}'
                        : '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
          Positioned(
            left: 16,
            top: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Câmera automática",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: isCameraAutoMove,
                  onChanged: (bool value) {
                    setState(() {
                      isCameraAutoMove = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: FutureBuilder<List<RouteModel>>(
              future: _routesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error, color: Colors.red);
                } else if (snapshot.hasData) {
                  final routes = snapshot.data!;

                  return ElevatedButton.icon(
                    onPressed: () async {
                      // verifica se o motorista esta com uma rota ativa
                      if (locationProvider.isTracking) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Não é possível mudar de rota enquanto o rastreamento estiver ativo.'),
                            backgroundColor: Colors.black,
                          ),
                        );
                        return;
                      }

                      final selected = await showMenu<RouteModel>(
                        context: context,
                        position: const RelativeRect.fromLTRB(1000, 70, 16, 0),
                        items: routes.map((route) {
                          return PopupMenuItem(
                            value: route,
                            child: Text(route.name),
                          );
                        }).toList(),
                      );

                      if (selected != null) {
                        setState(() {
                          selectedRoute = selected;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    icon: const Icon(
                      Icons.directions_bus_filled_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Rotas',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
