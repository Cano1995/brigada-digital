import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Para formatear la fecha
import '../data/bg_data.dart'; // Importar tu lista de fondos

class ToolsScreen extends StatefulWidget {
  
  final String truckId;
  final int selectedIndex; // Indica el índice del fondo a usar

  const ToolsScreen({super.key, required this.truckId, required this.selectedIndex});

  @override
  _ToolsScreenState createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  List<dynamic> tools = []; // Lista de herramientas
  List<dynamic> guardGroups = [];//lista de botones.
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now(); // Fecha seleccionada por defecto es la fecha actual
  String _selectedTurn = "Diurno"; // Turno seleccionado por defecto
  List<String> _selectedGuardGroups = []; // Grupos de guardia seleccionados
  String _user = "Usuario123"; // Aquí deberías obtener el usuario actual de alguna forma

  @override
  void initState() {
    super.initState();
    _fetchTools(); // Cargar herramientas al inicio
    _fetchGuardGroups(); // Cargar grupos de guardia
  }
  

  // Obtener herramientas por camión usando el truckId
  Future<void> _fetchTools() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://gc4529031ed9eb7-p3zpjccedme5d537.adb.sa-saopaulo-1.oraclecloudapps.com/ords/dev/apexfly/existencia?truckId=${widget.truckId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          tools = data['items']; // Asignar herramientas
        });
      } else {
        _showError("No se pudieron cargar las herramientas. ${widget.truckId}");
      }
    } catch (e) {
      _showError("Ocurrió un error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para obtener los grupos de guardia desde la API
Future<void> _fetchGuardGroups() async {
  try {
    final response = await http.get(
      Uri.parse('https://gc4529031ed9eb7-p3zpjccedme5d537.adb.sa-saopaulo-1.oraclecloudapps.com/ords/dev/apexfly/grupo_guardia'), // Cambia esta URL por la de tu API real
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        guardGroups = data['items']; // Supongamos que tu API devuelve un campo 'items'
      });
    } else {
      _showError("No se pudieron cargar los grupos de guardia.");
    }
  } catch (e) {
    _showError("Ocurrió un error al cargar los grupos de guardia: $e");
  }
}

  // Método para actualizar la existencia de la herramienta
  Future<void> _updateTool(String toolId, bool exists, String observation, int quantity) async {
    if (observation.isEmpty) {
      _showError("La observación no puede estar vacía.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://gc4529031ed9eb7-p3zpjccedme5d537.adb.sa-saopaulo-1.oraclecloudapps.com/ords/dev/apexfly/update_existencia'), // Cambia por tu endpoint real
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toolId': toolId,
          'exists': exists,
          'observation': observation,
          'quantity': quantity, // Enviar la cantidad actualizada
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _showSuccess("Existencia y cantidad actualizadas.");
          _fetchTools();  // Refrescar los datos después de la actualización
        } else {
          _showError(data['message']);
        }
      } else {
        _showError("Error al actualizar la herramienta.");
      }
    } catch (e) {
      _showError("Ocurrió un error: $e");
    }
  }

  // Mostrar un mensaje de error
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Mostrar un mensaje de éxito
  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Éxito"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Enviar datos a la API
  Future<void> _submitForm() async {
    try {
      final response = await http.post(
        Uri.parse('https://tu-api.com/guardar_datos'), // Cambia por tu endpoint real
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': DateFormat('dd-MM-yyyy').format(_selectedDate),
          'turn': _selectedTurn,
          'guardGroups': _selectedGuardGroups,
          'user': _user, // Usuario actual
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _showSuccess("Datos guardados con éxito.");
        } else {
          _showError(data['message']);
        }
      } else {
        _showError("Error al guardar los datos.");
      }
    } catch (e) {
      _showError("Ocurrió un error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Para adaptar el diseño

    return Scaffold(
      appBar: AppBar(
        title: const Text("Herramientas del Camión"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgList[widget.selectedIndex]), // Fondo basado en el índice
            fit: BoxFit.cover, // Asegura que el fondo cubra toda la pantalla
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), // Fondo semitransparente para el contenido
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selección de fecha
              Row(
                children: [
                  Text("Fecha: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}",
                  style: TextStyle(color: Colors.white),),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              
              // Selección de turno
              DropdownButton<String>(
                value: _selectedTurn,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTurn = newValue!;
                  });
                },
                items: <String>['Diurno', 'Nocturno']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: TextStyle(color: Colors.white),),
                  );
                }).toList(),
              ),

              // Selección de grupos de guardia
              // Selección de grupos de guardia con color y check
              Wrap(
                  spacing: 8.0,
                  children: guardGroups.map((group) {
                    return FilterChip(
                      label: Text(group['nombre']), // Usa el nombre del grupo desde la API
                      selected: _selectedGuardGroups.contains(group['id'].toString()),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            // Si se selecciona el chip, limpia la selección actual y selecciona el nuevo
                            _selectedGuardGroups.clear();
                            _selectedGuardGroups.add(group['id'].toString());
                          } else {
                            // Si se deselecciona, se limpia la selección
                            _selectedGuardGroups.clear();
                          }
                        });
                        // Imprimir en la consola el estado actual de la lista seleccionada
          print('imprimiendo: $_selectedGuardGroups');
                      },
                      selectedColor: Colors.blue, // Color del chip cuando está seleccionado
                      avatar: _selectedGuardGroups.contains(group['id'])
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    );
                  }).toList(),
                ),



              
              // Lista de herramientas
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: tools.length,
                        itemBuilder: (context, index) {
                          final tool = tools[index];
                          return Card(
                            color: Colors.white.withOpacity(0.8),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(
                                tool['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('obs: ${tool['obs']}'), // Nuevo subtítulo
                                        Text('Existencia: ${tool['quantity']}'),
                                      ],
                                    ),
                              //subtitle: Text('Existencia: ${tool['quantity']}'),
                              trailing: Checkbox(
                                value: tool['exists'] == 1,
                                onChanged: (bool? value) {
                                  if (value != null && !value) {
                                    // Si la existencia no corresponde, abre un formulario para ingresar la observación y cantidad
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        TextEditingController observationController = TextEditingController();
                                        TextEditingController quantityController = TextEditingController();
                                        return AlertDialog(
                                          title: const Text("Actualizar Existencia"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                controller: observationController,
                                                decoration: const InputDecoration(
                                                  labelText: 'Observación',
                                                ),
                                              ),
                                              TextField(
                                                controller: quantityController,
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  labelText: 'Cantidad',
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                _updateTool(
                                                  tool['id'].toString(),
                                                  false,
                                                  observationController.text,
                                                  int.parse(quantityController.text),
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Aceptar"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("Cancelar"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Botón Aceptar
              //Spacer(),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Aceptar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
