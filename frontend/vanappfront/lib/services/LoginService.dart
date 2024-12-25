import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../main.dart';

class LoginService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> login(String email, String password) async {
    final url = Uri.parse('http://192.168.1.10:3000/login');

    final body = json.encode({
      'email': email,
      'password': password,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200){
      throw Exception("Falha ao realizar login: ${response.statusCode}");
    }

    final responseData = json.decode(response.body);
    final jwtToken = responseData['jwtToken'];

    if (jwtToken == null){
      throw Exception('Falha ao autenticar.');
    }

    _secureStorage.write(key:'jwtToken',value:jwtToken);
  }

  static Future<void> logout() async {
    await _secureStorage.delete(key: 'jwtToken');
  }

  static Future<bool> isUserLoggedIn() async {
     String? jwtToken = await _secureStorage.read(key: "jwtToken");

     if (jwtToken == null) return false;

     return !isTokenExpired(jwtToken);
  }

  static bool isTokenExpired(String? token) {
    if (token == null) return true;
    return JwtDecoder.isExpired(token);
  }

  static void onExpiratedSession(BuildContext context){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sessão expirada. Por favor, faça login novamente'),
        backgroundColor: Colors.orangeAccent,
        duration: Duration(seconds: 4),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
