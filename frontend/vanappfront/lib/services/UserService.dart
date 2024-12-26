import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../Exceptions/AuthenticationException.dart';
import '../models/RegisterUserModel.dart';
import '../models/UserModel.dart';
import 'LoginService.dart';


class UserService {

  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();


  static Future<List<UserModel>?> getUsers() async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/users');

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
        print('Falha ao buscar usuarios: ${response.statusCode}');
        return [];
      }

      final List<dynamic> usersJson = json.decode(response.body);

      List<UserModel> filteredUsers = usersJson.map((route) => UserModel.fromJson(route)).toList();
      return filteredUsers;
    } catch (e) {
      print('Falha ao buscar usuarios: $e');
      return [];
    }
  }

  static Future<UserModel?> getUser() async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/users/userInfo');

      String? jwtToken = await _secureStorage.read(key: "jwtToken");

      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken,
        },
      );

      if (response.statusCode != 200) {
        print('Falha ao buscar usuario: ${response.statusCode}');
        return null;
      }

      final dynamic userJson = json.decode(response.body);

      UserModel user = UserModel.fromJson(userJson);

      return user;
    } catch (e) {
      print('Falha ao buscar usuario: $e');
      return null;
    }
  }

  static Future<bool> createUser(RegisterUserModel user) async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/users/');

      final userJson = json.encode({
        'user': user.toJson(),
      });

      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: userJson
      );

      if (response.statusCode != 200) {
        print('Falha ao cadastrar usuario: ${response.statusCode}');
        return false;
      }
      // sucesso ao cadastrar
      return true;
    } catch (e) {
      print('Erro ao cadastrar usuario: $e');
      return false;
    }
  }


  static Future<List<UserModel>?> getUsersByQuery(String searchQuery) async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/users/$searchQuery');

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
        print('Falha ao buscar usuarios: ${response.statusCode}');
        return [];
      }

      final List<dynamic> filteredUsersJson = json.decode(response.body);

      List<UserModel> filteredUsers = filteredUsersJson.map((route) => UserModel.fromJson(route)).toList();
      return filteredUsers;
    } catch (e) {
      print('Falha ao buscar usuarios: $e');
      return [];
    }
  }

  static Future<bool> verifyUserIsDriver() async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/users/isDriver/');

      String? jwtToken = await _secureStorage.read(key:"jwtToken");

      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': jwtToken,
        },
      );

      if (response.statusCode != 200){
        print('Falha ao verificar se o usuario eh um motorista ativo: ${response.statusCode}');
        return false;
      }

      final responseData = json.decode(response.body);
      final isDriver = responseData["isDriver"] ?? false;

      return isDriver;

    } catch (e) {
      print('Erro ao verificar se é motorista: $e');
      return false;
    }
  }

  static Future<bool> verifyUserIsRouteDriver(String routeId) async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/users/isDriver/routes/$routeId');

      String? jwtToken = await _secureStorage.read(key:"jwtToken");

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

      if (response.statusCode != 200){
        print('Falha ao verificar se o usuario eh o motorista da rota: ${response.statusCode}');
        return false;
      }

      final responseData = json.decode(response.body);
      final isDriver = responseData["isDriver"] ?? false;
      return isDriver;

    } catch (e) {
      print('Erro ao verificar se o usuario eh motorista da rota: $e');
      return false;
    }
  }

  static Future<Map<String, bool>> verifyUserIsRoutesDriver(List<String> routesId, bool isDriver) async {
    Map<String, bool> routeDriverMap = {};
    if (!isDriver){
      // caso o usuario nao seja motorista
      for (var routeId in routesId) {
        routeDriverMap[routeId] = false;
      }
      return routeDriverMap;
    }
    try {
      final url = Uri.parse('http://192.168.1.10:3000/users/isDriver/routes/');

      String? jwtToken = await _secureStorage.read(key: "jwtToken");

      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }

      final body = json.encode({
        'routes': routesId,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> isDriverResults = responseData['isDriverResults'];

        for (var result in isDriverResults) {
          routeDriverMap[result['routeId']] = result['isRouteDriver'] ?? false;
        }

      } else {
        print('Falha ao verificar se o usuario eh o motorista das rotas: ${response.statusCode}');

        for (var routeId in routesId) {
          routeDriverMap[routeId] = false;
        }
      }
    } catch (e) {
      print('Erro ao verificar se o usuario eh motorista das rotas: $e');

      for (var routeId in routesId) {
        routeDriverMap[routeId] = false;
      }
    }

    return routeDriverMap;
  }

  static Future<bool> deleteUserFromRoute(String passengerId,String routeId) async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/users/routes/');

      String? jwtToken = await _secureStorage.read(key:"jwtToken");

      if (jwtToken == null || LoginService.isTokenExpired(jwtToken)) {
        throw AuthenticationException();
      }

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken,
        },
        body: json.encode({
        'passengerId': passengerId,
        'routeId': routeId,
        })
      );

      if (response.statusCode != 200){
        print('Falha ao remover usuário da rota: ${response.statusCode}');
        return false;
      }

      return true;

    } catch (e) {
      print('Erro ao remover usuário da rota: $e');
      return false;
    }
  }

  static Future<String?> getUserDeviceToken(UserModel user) async {
    try {
      final url = Uri.parse('http://192.168.1.10:3000/users/${user.id}/deviceToken');

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
        print('Falha ao recuperar device token do usuario: ${response.statusCode}');
      }

      String? deviceToken = json.decode(response.body)['deviceToken'];

      return deviceToken;

    } catch (e) {
      print('Falha ao recuperar device token do usuario: $e');
    }
  }
}
