import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  String rol = '2'; // 1 = Admin, 2 = Estudiante, 3 = Docente, 13 = Vinculación
  String carrera = '1'; // Código real de la carrera según tu BD
  String mensaje = '';
  bool cargando = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> registrarUsuario() async {
    setState(() {
      mensaje = '';
      cargando = true;
    });

    if (passCtrl.text.trim() != confirmPassCtrl.text.trim()) {
      setState(() {
        mensaje = "❌ Las contraseñas no coinciden";
        cargando = false;
      });
      return;
    }

    if (nombreCtrl.text.trim().isEmpty ||
        apellidoCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        passCtrl.text.trim().isEmpty) {
      setState(() {
        mensaje = "⚠️ Por favor llena todos los campos";
        cargando = false;
      });
      return;
    }

    try {
      final res = await http.post(
        Uri.parse("${dotenv.env['BACKEND_URL']}/registrar_usuario.php"),
        body: {
          'nombre': nombreCtrl.text.trim(),
          'apellido': apellidoCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'password': passCtrl.text.trim(),
          'rol': rol,
          'carrera': carrera,
        },
      );

      final data = jsonDecode(res.body);
      setState(() {
        mensaje = data['success'] == true
            ? "✅ ${data['message']}"
            : "❌ ${data['message']}";
        cargando = false;
      });

      if (data['success'] == true) {
        nombreCtrl.clear();
        apellidoCtrl.clear();
        emailCtrl.clear();
        passCtrl.clear();
        confirmPassCtrl.clear();
      }
    } catch (e) {
      setState(() {
        mensaje = "❌ Error de conexión: $e";
        cargando = false;
      });
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    apellidoCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de usuario")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombres")),
            TextField(
                controller: apellidoCtrl,
                decoration: const InputDecoration(labelText: "Apellidos")),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration:
                  const InputDecoration(labelText: "Correo electrónico"),
            ),
            TextField(
              controller: passCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassCtrl,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: rol,
              decoration: const InputDecoration(labelText: "Rol"),
              onChanged: (value) => setState(() => rol = value!),
              items: const [
                DropdownMenuItem(value: '1', child: Text("Administrador")),
                DropdownMenuItem(value: '2', child: Text("Estudiante")),
                DropdownMenuItem(value: '3', child: Text("Docente")),
                DropdownMenuItem(value: '13', child: Text("Vinculación")),
              ],
            ),
            DropdownButtonFormField<String>(
              value: carrera,
              decoration: const InputDecoration(labelText: "Carrera"),
              onChanged: rol == '2'
                  ? (value) => setState(() => carrera = value!)
                  : null, // Deshabilitado si no es estudiante
              items: const [
                DropdownMenuItem(
                    value: '1',
                    child: Text(
                        "TECNOLOGIA SUPERIOR EN GESTION DE LA TECNOLOGIA DE LA INFORMACION")),
                DropdownMenuItem(
                    value: '2',
                    child: Text(
                        "TECNOLOGIA SUPERIOR EN ADMINISTRACION FINANCIERA")),
                DropdownMenuItem(
                    value: '3',
                    child: Text("TECNOLOGÍA SUPERIOR EN CONTABILIDAD")),
                DropdownMenuItem(
                    value: '4',
                    child:
                        Text("TECNOLOGIA SUPERIOR EN DESARROLLO DE SOFTWARE")),
                DropdownMenuItem(
                    value: '5',
                    child: Text("TECNOLOGIA SUPERIOR EN MARKETING")),
                DropdownMenuItem(
                    value: '6',
                    child: Text(
                        "TECNOLOGIA SUPERIOR EN REDES Y TELECOMUNICACIONES")),
                // Agrega aquí tus carreras reales
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: cargando ? null : registrarUsuario,
              child: cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Registrar"),
            ),
            const SizedBox(height: 12),
            Text(mensaje,
                style: TextStyle(
                    color: mensaje.contains("✅") ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}
