import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ToolsScreen.dart'; // Importa la pantalla de herramientas
import 'custom_drawer.dart'; // Importa el CustomDrawer
import 'login_screen.dart';
//import '../data/bg_data.dart'; // Asegúrate de tener este archivo con la lista bgList

// Este es un ejemplo de cómo puedes tener tu lista de imágenes.
import '../data/bg_data.dart'; // Asegúrate de tener este archivo con la lista bgList

class UbiScreen extends StatefulWidget {
  
  final String userName;  // Recibimos el nombre del usuario
  const UbiScreen({super.key,required this.userName});

  @override
  _UbiScreenState createState() => _UbiScreenState();
}

class _UbiScreenState extends State<UbiScreen> {
  List<dynamic> trucks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTrucks();
  }

  // Obtener lista de camiones desde la API
  Future<void> _fetchTrucks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://gc4529031ed9eb7-p3zpjccedme5d537.adb.sa-saopaulo-1.oraclecloudapps.com/ords/dev/apexfly/ubicaciones'),
      );
 print("El valor de la variable es: ${widget.userName}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          trucks = data['items']; // Usamos 'items' para obtener la lista de camiones
        });
      } else {
        _showError("No se pudieron cargar los camiones.");
      }
    } catch (e) {
      _showError("Ocurrió un error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mostrar un mensaje de error
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error", style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // Función para hacer logout
  void _logout() {
    // Lógica para cerrar sesión (limpiar datos de sesión si es necesario)
    Navigator.pop(context); // Cerrar el Drawer
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Has cerrado sesión"),
      duration: Duration(seconds: 2),
    ));

    // Redirigir a la pantalla de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Asegúrate de tener la pantalla de login
    );
  }

  // Método para actualizar la lista de camiones (refresh)
  void _refreshTrucks() {
    _fetchTrucks(); // Vuelve a obtener los camiones desde la API
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camiones de la Estación", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF78B3CE), // Fondo de la AppBar en verde
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Abre el CustomDrawer
              },
            );
          },
        ),
      ),
      drawer: CustomDrawer(selectedIndex: 0,
  userName: widget.userName,), // Usamos CustomDrawer aquí, puedes pasar el índice adecuado
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          // Aquí agregamos la imagen como fondo
          image: DecorationImage(
            image: AssetImage(bgList[0]), // Cambia el índice según sea necesario
            fit: BoxFit.fill, // Ajustamos la imagen para que cubra todo el espacio disponible
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator()) // Mientras carga
            : ListView.builder(
              
                itemCount: trucks.length,
                itemBuilder: (context, index) {
                  final truck = trucks[index];
                  return Card(
                    
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    color: const Color(0xFFE0F2F1), // Color del card (fondo claro)
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Text(
                        truck['camiones'], 
                        style: const TextStyle(
                          color: Color(0xFF00796B), // Color del texto del camión
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        // Navegar a la pantalla de herramientas, pasando el ID del camión
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ToolsScreen(
                              truckId: truck['id'].toString(), // Pasar el ID del camión como string
                              selectedIndex:0,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshTrucks, // Acción que se ejecuta al presionar el botón
        backgroundColor: const Color(0xFF00796B), // Color del botón
        child: const Icon(Icons.refresh), // Ícono de refresh
      ),
    );
  }
}
