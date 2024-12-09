import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:brigada_digital/utils/animations.dart';
import '../data/bg_data.dart';
import '../utils/text_utils.dart';
import 'home.dart';
import 'registro.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedIndex = 0;
  bool showOption = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    final String apiUrl = 'https://gc4529031ed9eb7-p3zpjccedme5d537.adb.sa-saopaulo-1.oraclecloudapps.com/ords/dev/apexfly/autenticacion'; // Cambia a tu endpoint
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  final userName = data['user']['name'];  // Guardamos el nombre del usuario
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Bienvenido, ${data['user']['name']}!')),
  );

  // Redirigir a la pantalla de inicio
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HomeScreen(userName: userName,selectedIndex: selectedIndex),
    ),
  );
} else {
  final error = jsonDecode(response.body);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error['message'] ?? 'Error al iniciar sesión')),
  );
}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 49,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
                child: showOption
                    ? ShowUpAnimation(
                        delay: 100,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: bgList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: selectedIndex == index
                                    ? Colors.white
                                    : Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: AssetImage(bgList[index]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox()),
            const SizedBox(width: 20),
            showOption
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = false;
                      });
                    },
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 30))
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = true;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(bgList[selectedIndex]),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
      body: Container(
  height: double.infinity,
  width: double.infinity,
  decoration: BoxDecoration(
    image: DecorationImage(
        image: AssetImage(bgList[selectedIndex]), fit: BoxFit.fill),
  ),
  alignment: Alignment.center,
  child: Container(
    height: 400,
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 30),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(15),
      color: Colors.black.withOpacity(0.1),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del ícono centrada
              Center(
                child: Image.asset(
                  'assets/imagenes/emblema.png', // Ruta de la imagen
                  height: 100.0, // Tamaño del ícono
                  width: 100.0, // Tamaño del ícono
                  fit: BoxFit.contain, // Asegura que la imagen no se distorsione y quede centrada
                ),
              ),
              const Spacer(),
              Center(
                  child: TextUtil(
                text: "Brigada Digital",
                weight: true,
                size: 30,
              )),
              const Spacer(),
              TextUtil(
                text: "Correo",
              ),
              Container(
                height: 35,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white))),
                child: TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    suffixIcon: Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                    fillColor: Colors.white,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Spacer(),
              TextUtil(
                text: "Contraseña",
              ),
              Container(
                height: 35,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white))),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    suffixIcon: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    fillColor: Colors.white,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: isLoading ? null : login,
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  alignment: Alignment.center,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : TextUtil(
                          text: "Ingresar",
                          color: Colors.black,
                        ),
                ),
                
              ),
              const Spacer(),const Spacer(),
                GestureDetector(
                  onTap: () {
                    // Navegar a la página de registro
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()), // Crearemos RegisterScreen después
                    );
                  },
                  child: Center(
                    child: TextUtil(
                      text: "¿No tienes una cuenta? Regístrate",
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const Spacer(),

            ],
          ),
        ),
      ),
    ),
  ),
)
,
    );
  }
}
