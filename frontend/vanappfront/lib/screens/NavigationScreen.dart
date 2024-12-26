import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vanappfront/services/NavigationService.dart';
import '../services/DeviceTokenService.dart';
import '../services/LoginService.dart';
import '../services/UserService.dart';
import 'MapScreen.dart';
import 'MapScreen.dart';
import 'ProfileScreen.dart';
import 'RoutesScreen.dart';

class NavigationScreen extends StatefulWidget {

  const NavigationScreen({Key? key}) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final NavigationService _navigationService = NavigationService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> updateDeviceToken() async {
    try {
      String? deviceToken = await FirebaseMessaging.instance.getToken();

      String? deviceTokenStorage = await _secureStorage.read(key: "deviceToken");
      String? jwtToken = await _secureStorage.read(key: "jwtToken");
      // Verifica se o token foi alterado. Se foi alterado, salva no banco
      deviceTokenStorage = "";
      if (deviceToken != null && deviceToken != deviceTokenStorage) {
        await DeviceTokenService.saveDeviceToken(jwtToken, deviceToken);
        await _secureStorage.write(key: "deviceToken", value: deviceToken);
      }
    } catch (e) {
      print('Erro ao atualizar device token: $e');
    }
  }

  Future<Widget> navigateFromNavBar(int index, bool isDriver, BuildContext context) async {
    switch (index) {
      case 0:
          Widget mapWidget = await _navigationService.navigateFromNavBar(() => const MapScreen(), context);
          return mapWidget;
      case 1:
        if (isDriver){
          Widget passengersWidget = await _navigationService.navigateFromNavBar(() => const RoutesScreen(), context);
          return passengersWidget;
        } else {
          Widget profileWidget = await _navigationService.navigateFromNavBar(() => const ProfileScreen(),context);
          return profileWidget;
        }
      case 2:
        Widget profileWidget = await _navigationService.navigateFromNavBar(() => const ProfileScreen(),context);
        return profileWidget;
      default:
          Widget mapWidget = await _navigationService.navigateFromNavBar(() => const MapScreen(), context);
          return mapWidget;
      }
  }

  @override
  void initState() {
    super.initState();
    updateDeviceToken();
  }

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: UserService.verifyUserIsDriver(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('VanApp')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          // Caso ocorra erro ao carregar a tela, mostra mensagem e redireciona
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoginService.onExpiratedSession(context);
          });
          return const Center();
        } else {
          return Scaffold(
            bottomNavigationBar: NavigationBar(
              backgroundColor: Colors.grey[300],
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              selectedIndex: currentPageIndex,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.location_pin),
                  label: 'Mapa',
                ),
                if (snapshot.data!)  // Somente um motorista pode gerenciar rotas
                  const NavigationDestination(
                    icon: Icon(Icons.directions_bus_filled_rounded),
                    label: 'Rotas',
                  ),
                const NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Perfil'
                )
              ],
            ),
            body: FutureBuilder<Widget>(
              // snapshot.data -> true se o usuario eh motorista, false caso contrario
              future: navigateFromNavBar(currentPageIndex,snapshot.data ?? false, context),
              builder: (context, innerSnapshot) {
                if (innerSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (innerSnapshot.hasError) {
                  // Caso ocorra erro ao carregar a tela, mostra mensagem e redireciona
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    LoginService.onExpiratedSession(context);
                  });

                  return const Center();
                } else if (innerSnapshot.hasData) {
                  return innerSnapshot.data!;
                } else {
                  return const Center(child: Text('Nenhum dado encontrado.'));
                }
              },
            ),
          );
        }
      },
    );
  }

}
