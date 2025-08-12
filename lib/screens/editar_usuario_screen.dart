import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditarUsuarioScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const EditarUsuarioScreen({super.key, required this.usuario});

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  late TextEditingController nombreCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;
  String? rolSeleccionado;
  String? carreraSeleccionada;

  List<Map<String, dynamic>> roles = [];
  List<Map<String, dynamic>> carreras = [];

  bool loadingRoles = true;
  bool loadingCarreras = true;

  @override
  void initState() {
    super.initState();
    nombreCtrl =
        TextEditingController(text: widget.usuario['Nombre_Usuario'] ?? '');
    emailCtrl =
        TextEditingController(text: widget.usuario['Email_Usuario'] ?? '');
    passwordCtrl = TextEditingController();
    rolSeleccionado = widget.usuario['Codigo_Rol']?.toString();
    carreraSeleccionada = widget.usuario['Codigo_Carrera']?.toString();

    cargarRoles();
    cargarCarreras();
  }

  Future<void> cargarRoles() async {
    final response = await http
        .get(Uri.parse("${dotenv.env['BACKEND_URL']}/listar_roles.php"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        roles = List<Map<String, dynamic>>.from(data);
        loadingRoles = false;
      });
    } else {
      setState(() => loadingRoles = false);
    }
  }

  Future<void> cargarCarreras() async {
    final response = await http
        .get(Uri.parse("${dotenv.env['BACKEND_URL']}/listar_carreras.php"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        carreras = List<Map<String, dynamic>>.from(data);
        loadingCarreras = false;
      });
    } else {
      setState(() => loadingCarreras = false);
    }
  }

  Future<void> guardarCambios() async {
    final nombre = nombreCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    final rol = rolSeleccionado;
    final carrera = carreraSeleccionada;
    final codigo = widget.usuario['Codigo_Usuario']?.toString();

    if (nombre.isEmpty ||
        email.isEmpty ||
        rol == null ||
        carrera == null ||
        codigo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Todos los campos son obligatorios")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("${dotenv.env['BACKEND_URL']}/actualizar_usuario.php"),
      body: {
        'codigo': codigo,
        'email': email,
        'nombre': nombre,
        'rol': rol,
        'carrera': carrera,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Usuario actualizado correctamente")),
        );
        Navigator.pop(context);
      } else {
        final msg = json['error'] ?? "Error desconocido";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $msg")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al conectar con el servidor")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2DF), // Fondo crema claro
      appBar: AppBar(
        title: const Text("Editar Usuario"),
        backgroundColor: const Color(0xFFD90B13), // Rojo personalizado
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: InputDecoration(
                labelText: "Nombre",
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: "Correo",
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordCtrl,
              decoration: InputDecoration(
                labelText: "Nueva contraseña",
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            loadingRoles
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: rolSeleccionado,
                    decoration: InputDecoration(
                      labelText: "Rol",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: roles
                        .map((rol) => DropdownMenuItem<String>(
                              value: rol['Codigo_Rol'].toString(),
                              child: Text(rol['Nombre_Rol']),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => rolSeleccionado = val),
                  ),
            const SizedBox(height: 10),
            loadingCarreras
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: carreraSeleccionada,
                    decoration: InputDecoration(
                      labelText: "Carrera",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: carreras
                        .map((carrera) => DropdownMenuItem<String>(
                              value: carrera['Codigo_Carrera'].toString(),
                              child: Text(carrera['Nombre_Carrera']),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => carreraSeleccionada = val),
                  ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Guardar Cambios"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD90B13), // Rojo personalizado
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: guardarCambios,
            ),
          ],
        ),
      ),
    );
  }
}
