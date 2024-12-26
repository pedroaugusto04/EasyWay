import 'package:flutter/material.dart';
import 'package:vanappfront/models/UserModel.dart';
import 'dart:async';
import '../models/RouteModel.dart';
import '../services/RoutesService.dart';
import '../services/UserService.dart';

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({Key? key}) : super(key: key);

  @override
  _CreateRouteScreenState createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _searchQuery = TextEditingController();
  List<UserModel> _passengers = [];
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  Timer? _debounce;
  String searchText = "";

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _originFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _filteredUsers = _allUsers;
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
                          // passageiros ja selecionados nao devem aparecer
                          _debounce?.cancel();
                          _debounce = Timer(const Duration(milliseconds: 300), () {
                            setDialogState(() {
                              _filteredUsers = _allUsers
                                  .where((user) =>
                              (user.name.toLowerCase().contains(query.toLowerCase()) ||
                                  user.email.toLowerCase().contains(query.toLowerCase())) &&
                                  !_passengers.any((passenger) => passenger.id == user.id))
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
                              onTap: () {
                                setState(() {
                                  _passengers.add(_filteredUsers[index]);
                                  // ja adicionado nao deve aparecer na busca
                                  _filteredUsers.removeAt(index);
                                });
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


  @override
  void dispose() {
    _searchQuery.dispose();
    _debounce?.cancel();
    _nameFocusNode.dispose();
    _originFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Rota'),
      ),
      body: GestureDetector(
        // Detecta o clique fora dos campos de texto e desfoca
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Rota',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome da rota.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _originController,
                    focusNode: _originFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Local de Origem',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o local de origem.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _destinationController,
                    focusNode: _destinationFocusNode, // Definindo o FocusNode
                    decoration: const InputDecoration(
                      labelText: 'Local de destino',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o local de destino.';
                      }
                      return null;
                    },
                  ),
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
                          style: TextStyle(color: Colors.white)
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _passengers.isEmpty ? 1 : _passengers.length,
                    itemBuilder: (context, index) {
                      if (_passengers.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhum passageiro foi adicionado ainda',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }
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
                            _passengers[index].name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            _passengers[index].email,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _passengers.removeAt(index);
                                _filteredUsers = _allUsers
                                    .where((user) =>
                                !_passengers.any((passenger) => passenger.id == user.id))
                                    .toList();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Passageiro removido com sucesso!'),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(30.0),
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()){

              final routeName = _nameController.text;
              final origin = _originController.text;
              final destination = _destinationController.text;

              final newRoute = RouteModel(
                id: '',
                name: routeName,
                origin: origin,
                destination: destination,
                passengers: _passengers,
              );

              await RoutesService.createRoute(newRoute);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Rota criada com sucesso!')),
              );

              Navigator.pop(context,true); // volta para a tela de rotas
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Colors.blue,
          ),
          child: Text(
            'Criar Rota',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
