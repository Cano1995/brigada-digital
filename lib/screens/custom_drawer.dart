import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para gestionar el almacenamiento local
import 'package:brigada_digital/screens/home.dart';
import 'package:brigada_digital/screens/login_screen.dart';
import '../data/bg_data.dart'; // Asegúrate de importar el archivo bg_data.dart
import 'ubicaciones.dart';
//import 'home.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;

  const CustomDrawer({super.key, required this.selectedIndex});

  // Función para hacer logout
  Future<void> _logout(BuildContext context) async {
    // Limpiar los datos de sesión utilizando SharedPreferences (o la solución que uses)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken'); // Borra el token o cualquier dato de sesión que guardes

    // Muestra un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has cerrado sesión exitosamente.')),
    );

    // Redirige a la pantalla de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Asegúrate de tener la pantalla de login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del Drawer
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bgList[selectedIndex]), // Usa el índice para seleccionar la imagen
                fit: BoxFit.cover,
              ),
            ),
            child: const Text(
              'Menú Principal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Lista de elementos del menú
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Inicio"),
            onTap: () {
              Navigator.pop(context); // Cerrar el menú
              // Aquí navegas a la pantalla de Inicio
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen(userName: '',selectedIndex: 0)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Perfil"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad pendiente...')),
              );
              Navigator.pop(context); // Cerrar el menú
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_business_outlined),
            title: const Text("Inventario"),
            onTap: () {
              Navigator.pop(context);
              // Aquí navegas a la pantalla de Ubicación
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UbiScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad pendiente...')),
              );
              Navigator.pop(context); // Cerrar el menú
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: () {
              Navigator.pop(context); // Cerrar el menú
              _logout(context); // Llamar la función de logout
            },
          ),
        ],
      ),
    );
  }
}
