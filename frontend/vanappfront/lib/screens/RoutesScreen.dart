import 'package:flutter/material.dart';
import 'package:vanappfront/screens/RouteDetailsScreen.dart';
import 'package:vanappfront/services/RoutesService.dart';
import '../models/RouteModel.dart';
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
    _routesFuture = RoutesService.getRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<RouteModel>?>(
            future: _routesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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
                        subtitle: Text(
                          'Origem: ${route.origin}\nDestino: ${route.destination}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RouteDetailsScreen(route: route)),
                            );
                          },
                          child: const Text('Detalhes'),
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
              child: const Icon(Icons.add),
              tooltip: 'Criar Rota',
            ),
          ),
        ],
      ),
    );
  }
}
