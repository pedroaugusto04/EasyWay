import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/network/NetworkManagerProvider.dart';
import '../services/LoginService.dart'; // Importe o LoginService

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkManagerProvider>(context);
    return FutureBuilder<bool>(
      future: LoginService.isUserLoggedIn(), // Verifica se o usuário está logado
      builder: (context, snapshot) {
        // enquanto estiver carregando
        if (snapshot.connectionState == ConnectionState.waiting
            || networkProvider.connectivityStatus == ConnectivityResult.none) {
          return AppBar(
            title: const Text('EasyWay'),
            actions: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ], // Exibe um indicador de progresso enquanto espera
          );
        }

        // Se houver algum erro ou o usuário não estiver logado
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == false) {
          // caso nao esteja logado
          return AppBar(
            title: const Text('EasyWay'),
          );
        }

        // caso esteja logado
        return AppBar(
          title: const Text('EasyWay'),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _logout(BuildContext context) {
    LoginService.logout();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Logout realizado com sucesso!'),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
