import 'package:flutter/material.dart';
import '../models/RouteModel.dart';
import '../models/UserModel.dart';
import '../services/UserService.dart';
import 'UserMapScreen.dart';

class RouteDetailsScreen extends StatefulWidget {
  final RouteModel route;

  const RouteDetailsScreen({Key? key, required this.route}) : super(key: key);

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  bool _isExpanded = true;

  Future<bool> _showDeleteConfirmation(BuildContext context, UserModel passenger) async {
    bool result = await showDialog (
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir o passageiro ${passenger.name} da rota?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await UserService.deleteUserFromRoute(passenger.id, widget.route.id);
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passageiro ${passenger.name} excluído!')),
                );
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    ) ?? false;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Rota: ${widget.route.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Text('Nome: ${widget.route.name}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8.0),
            Text('Origem: ${widget.route.origin}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8.0),
            Text('Destino: ${widget.route.destination}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8.0),
            const SizedBox(height: 24.0),

            // Texto "Passageiros"
            Text(
              'Passageiros:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 30.0,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),

            _isExpanded
                ? widget.route.passengers.isEmpty
                ? Text('Nenhum passageiro na rota.')
                : Expanded(
              child: ListView.builder(
                itemCount: widget.route.passengers.length,
                itemBuilder: (context, index) {
                  final passenger = widget.route.passengers[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      leading: CircleAvatar(
                        radius: 20.0,
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        passenger.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        passenger.email,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.location_pin, size: 20),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UserMapScreen(user: passenger,)));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () async {
                              // Exibe o modal de confirmação de exclusão
                              bool isDeleted = await _showDeleteConfirmation(context, passenger);
                              if (isDeleted) {
                                setState(() {
                                  widget.route.passengers.remove(passenger);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
                : Container(), // Se não estiver expandido, mostra nada
          ],
        ),
      ),
    );
  }
}
