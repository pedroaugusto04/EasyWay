import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart';
import '../screens/MapScreen.dart';
import 'LoginService.dart';

class NavigationService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<Widget> navigateFromNavBar(Widget Function() screen,BuildContext context) async {
    /* redirecionamento a partir da barra de navegacao, evita que as telas
    se sobreponham
     */
    bool isUserLoggedIn = await LoginService.isUserLoggedIn();
    if (!isUserLoggedIn && screen != const LoginScreen()) {
      // usuario nao autenticado -> redireciona para a tela de login
      return const LoginScreen();
    } else {
      // usuario logado, mantem a navegacao
      return screen();
    }
  }

  Future<void> navigateTo(Widget screen,BuildContext context) async {
    bool isUserLoggedIn = await LoginService.isUserLoggedIn();
    if (!isUserLoggedIn && screen != const LoginScreen()) {
      // usuario nao autenticado -> redireciona para a tela de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } else {
      // usuario logado, mantem a navegacao
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }
}
