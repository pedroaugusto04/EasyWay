import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanappfront/screens/RouteDetailsScreen.dart';
import 'package:vanappfront/services/RoutesService.dart';
import '../models/RouteModel.dart';
import '../providers/network/NetworkManagerProvider.dart';
import '../widgets/CustomAppBar.dart';
import 'CreateRouteScreen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({Key? key}) : super(key: key);

  @override
  _RoutesScreenState createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  late Future<List<RouteModel>?> _routesFuture;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  void _fetchRoutes() {
    _routesFuture = RoutesService.getRoutesDrivenByUser();
  }

  Future<bool> _confirmRemoveRoute(RouteModel route) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar remoção'),
          content: Text('Tem certeza de que deseja remover a rota "${route.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await RoutesService.deleteRoute(route.id);
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rota ${route.name} excluída!')),
                );
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final networkManager = Provider.of<NetworkManagerProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          FutureBuilder<List<RouteModel>?>(
            future: _routesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting
                  || networkManager.connectivityStatus == ConnectivityResult.none) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Você ainda não cadastrou nenhuma rota.'),
                );
              } else {
                final routes = snapshot.data!;
                return ListView.builder(
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.directions_bus,
                          size: 40.0,
                          color: Colors.blue,
                        ),
                        title: Text(route.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Garantir que os botões não ocupem espaço extra
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RouteDetailsScreen(route: route)),
                                );
                              },
                              child: const Text('Detalhes'),
                            ),
                            const SizedBox(width: 8.0),
                            ElevatedButton(
                              onPressed: () async {
                                bool isDeleted = await _confirmRemoveRoute(route);
                                if (isDeleted) {
                                  setState(() {
                                    routes.remove(route);
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: CircleBorder(),
                              ),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 18.0,
                              ),
                            ),
                          ],

                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () async {
                final bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateRouteScreen()),
                );

                // // Recarrega os dados das rotas
                if (result == true) {
                  setState(() {
                    _fetchRoutes();
                  });
                }
              },
              tooltip: 'Criar Rota',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
