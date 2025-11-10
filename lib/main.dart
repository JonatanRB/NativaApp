import 'package:admin_proyect_nuevo/screens/welcomeScreen.dart';
import 'package:admin_proyect_nuevo/screens/login2.dart';
import 'package:admin_proyect_nuevo/screens/register.dart';
import 'package:admin_proyect_nuevo/screens/menuscreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nativa',
      debugShowCheckedModeBanner: false,

      // Cambia la ruta inicial aquí
      initialRoute: '/welcomeScreen',

      // Define las rutas de la aplicación, incluyendo '/welcomeScreen'
      routes: {
        '/welcomeScreen': (context) => const WelcomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen2(),
        '/menu': (context) => const MenuScreen(),
      },
    );
  }
}