import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vanappfront/services/LoginService.dart';

import '../Exceptions/AuthenticationException.dart';
import '../models/RouteModel.dart';

class RoutesService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> createRoute(RouteModel route) async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/routes/');

      String? jwtToken = await _secureStorage.read(key: "jwtToken");

      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }

      final routeJson = json.encode({
        'route': route.toJson(),
      });


      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken,
        },
        body: routeJson
      );

      if (response.statusCode != 200) {
        print('Falha ao buscar rotas: ${response.statusCode}');
        return null;
      }

    } catch (e) {
      print('Erro ao verificar rotas: $e');
      return null;
    }
  }

  static Future<List<RouteModel>?> getRoutes() async {

    try {
      final url = Uri.parse('http://192.168.1.10:3000/routes/');

      String? jwtToken = await _secureStorage.read(key: "jwtToken");

      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken,
        },
      );

      if (response.statusCode != 200) {
        print('Falha ao buscar rotas: ${response.statusCode}');
        return null;
      }

      final List<dynamic> routesJson = json.decode(response.body);

      final List<RouteModel> routes = routesJson.map((dynamic item) {
        return RouteModel.fromJson(item as Map<String, dynamic>);
      }).toList();
      return routes;
    } catch (e) {
      print('Erro ao verificar rotas: $e');
      return null;
    }
  }
}
