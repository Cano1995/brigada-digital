import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart'; // Asegúrate de que esta importación sea correcta.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => const LoginScreen(), // Ruta inicial (LoginScreen)
        '/login_screen': (context) => const LoginScreen(), // Asegúrate de que LoginScreen esté aquí también
      },
    );
  }
}
