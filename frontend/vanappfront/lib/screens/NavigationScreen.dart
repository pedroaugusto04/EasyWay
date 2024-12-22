import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'MapScreen.dart';
import 'PassengersScreen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  Future<void> updateFirebaseToken() async {

  }

  @override
  void initState() {
    super.initState();
    updateFirebaseToken();
  }

  int currentPageIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const MapScreen(),
    const PassengersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VanApp'),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey[300],
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_pin),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Passageiros',
          ),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}
