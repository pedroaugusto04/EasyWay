import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../Exceptions/AuthenticationException.dart';
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
          'Content-Type': 'application/json',
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

      print("OK");
      print(response);

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
}
