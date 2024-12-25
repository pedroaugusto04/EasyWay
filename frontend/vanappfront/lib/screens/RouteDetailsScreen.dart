import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/RouteModel.dart';
import '../models/UserModel.dart';
import '../providers/RouteLocationProvider.dart';
import '../services/RoutesService.dart';
import '../services/UserService.dart';
import 'UserMapScreen.dart';

class RouteDetailsScreen extends StatefulWidget {
  final RouteModel route;

  const RouteDetailsScreen({Key? key, required this.route}) : super(key: key);

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  bool _isExpanded = false;
  final _searchQuery = TextEditingController();
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  Timer? _debounce;
  String searchText = "";

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _filteredUsers = _allUsers;
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, UserModel passenger) async {
    bool result = await showDialog(
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

  void _showAddPassengerModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Buscar Usuário'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchQuery,
                      decoration: InputDecoration(
                        labelText: 'Nome ou E-mail',
                        hintText: 'Digite o nome ou e-mail',
                      ),
                        onChanged: (query) {
                          // busca por similaridade de nome e email
                          // passageiros ja presentes na rota nao devem aparecer
                          if (_debounce?.isActive ?? false) {
                            _debounce?.cancel();
                          }
                          _debounce = Timer(const Duration(milliseconds: 300), () {
                            setDialogState(() {
                              _filteredUsers = _allUsers
                                  .where((user) =>
                              (user.name.toLowerCase().contains(query.toLowerCase()) ||
                                  user.email.toLowerCase().contains(query.toLowerCase())) &&
                                  !widget.route.passengers.any((passenger) => passenger.id == user.id))
                                  .toList();
                            });
                          });
                        }
                    ),
                    SizedBox(height: 16.0),
                    if (_filteredUsers.isNotEmpty)
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_filteredUsers[index].name),
                              onTap: () async {
                                // modal de confirmacao para adicao do passageiro
                                bool result = await _showConfirmationDialog(context,_filteredUsers[index]);
                                Navigator.pop(context);
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                          itemCount: _filteredUsers.length,
                        ),
                      )
                    else
                      Text(
                        'Nenhum usuário encontrado.',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context, UserModel passenger) async {
    bool result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Adição'),
          content: Text(
              'Tem certeza que deseja adicionar o passageiro "${passenger.name}" à rota?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Adiciona o passageiro à rota
                await RoutesService.addPassengerToRoute(widget.route.id, passenger.id);
                setState(() {
                  widget.route.passengers.add(passenger);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passageiro adicionado com sucesso!')),
                );
                Navigator.pop(context, true);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
    return result;
  }

  Future<void> _loadUsers() async {
    try {
      List<UserModel> listSearch = await UserService.getUsers() ?? [];
      setState(() {
        _allUsers = listSearch;
      });
    } catch (e) {
      print("Erro ao carregar usuários: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<RouteLocationProvider>(context);
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
                ? Center(
              child: Text(
                'Nenhum passageiro na rota.',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: widget.route.passengers.length,
                itemBuilder: (context, index) {
                  final passenger = widget.route.passengers[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5.0,
                    child: ListTile(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                                MaterialPageRoute(
                                  builder: (context) => UserMapScreen(
                                    user: passenger,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () async {
                              // verifica se o motorista está em rota
                              if (locationProvider.isTracking) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Não é possível mudar de rota enquanto o rastreamento estiver ativo.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Exibe o modal de confirmação de exclusão
                              bool isDeleted =
                              await _showDeleteConfirmation(context, passenger);
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
                : Container(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  _showAddPassengerModal(context);
                },
                child: Text(
                  'Adicionar Passageiro',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

