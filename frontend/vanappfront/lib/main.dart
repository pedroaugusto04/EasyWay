import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:vanappfront/providers/RouteLocationProvider.dart';
import 'package:vanappfront/providers/UserRouteLocationProvider.dart';
import 'package:vanappfront/screens/NavigationScreen.dart';
import 'package:vanappfront/screens/RegisterScreen.dart';
import 'package:vanappfront/services/LoginService.dart';
import 'package:vanappfront/services/NavigationService.dart';
import 'package:vanappfront/widgets/CustomAppBar.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default',
            'default',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RouteLocationProvider()),
        ChangeNotifierProvider(create: (context) => UserRouteLocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VanApp',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF007BFF),
          onPrimary: Colors.white,
          secondary: Color(0xFF007BFF),
          onSecondary: Colors.white,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[300],
        ),
      ),
      home: FutureBuilder<bool>(
        future: LoginService.isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: CustomAppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == false) {
            // caso nao esteja logado
            return const LoginScreen();
          }
          // caso esteja logado
          return const NavigationScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final NavigationService _navigationService = NavigationService();

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    bool isAuthenticated = await authenticateUser(email, password);

    if (isAuthenticated) {
      _navigationService.navigateTo(NavigationScreen(), context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciais inválidas')),
      );
    }
  }

  Future<bool> authenticateUser(String email, String password) async {
    try {
      await LoginService.login(email, password);
      return true;
    } catch (e) {
      print("Erro ao autenticar: $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Fecha o teclado quando o usuário toca fora de um campo de texto
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: const Text('Ainda não tem uma conta? Registre-se aqui'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
