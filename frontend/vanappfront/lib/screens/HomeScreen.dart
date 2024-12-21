import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text(
          'Bem-vindo à Tela Inicial!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
