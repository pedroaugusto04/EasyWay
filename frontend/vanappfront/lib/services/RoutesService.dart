import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vanappfront/services/LoginService.dart';
import '../exceptions/AuthenticationException.dart';
import '../models/RouteModel.dart';

class RoutesService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> createRoute(RouteModel route) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final url = Uri.parse('$apiUrl/routes/');

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
      }

    } catch (e) {
      print('Erro ao verificar rotas: $e');
    }
  }

  static Future<List<RouteModel>?> getRoutes() async {

    try {
      final apiUrl = dotenv.env['API_URL'];
      final url = Uri.parse('$apiUrl/routes/');

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


  static Future<List<RouteModel>?> getRoutesDrivenByUser() async {

    try {
      final apiUrl = dotenv.env['API_URL'];
      final url = Uri.parse('$apiUrl/routes/users/driven');

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
        print('Falha ao buscar rotas em que o usuario eh motorista: ${response.statusCode}');
        return null;
      }

      final List<dynamic> routesJson = json.decode(response.body);

      final List<RouteModel> routes = routesJson.map((dynamic item) {
        return RouteModel.fromJson(item as Map<String, dynamic>);
      }).toList();

      return routes;
    } catch (e) {
      print('Erro ao buscar rotas em que o usuario eh motorista: $e');
      return null;
    }
  }

  static Future<bool> deleteRoute(String routeId) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final url = Uri.parse('$apiUrl/routes/${routeId}');

      String? jwtToken = await _secureStorage.read(key:"jwtToken");

      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }

      final response = await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': jwtToken,
          }
      );

      if (response.statusCode != 200){
        print('Falha ao remover rota: ${response.statusCode}');
        return false;
      }

      return true;

    } catch (e) {
      print('Erro ao remover rota: $e');
      return false;
    }
  }

  static Future<void> addPassengerToRoute(String routeId, String passengerId) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final url = Uri.parse('$apiUrl/routes/${routeId}/passengers/${passengerId}');

      String? jwtToken = await _secureStorage.read(key:"jwtToken");

      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }

      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': jwtToken,
          }
      );

      if (response.statusCode != 200){
        print('Falha ao adicionar passageiro na rota: ${response.statusCode}');
      }

    } catch (e) {
      print('Erro ao adicionar passageiro na rota: $e');
    }
  }
}
