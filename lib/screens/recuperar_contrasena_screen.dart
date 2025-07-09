import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key});

  @override
  State<RecuperarContrasenaScreen> createState() =>
      _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  final emailCtrl = TextEditingController();
  String mensaje = '';
  bool cargando = false;

  Future<void> recuperar() async {
    setState(() {
      mensaje = '';
      cargando = true;
    });

    final res = await http.post(
      Uri.parse('${dotenv.env['BACKEND_URL']}/recuperar_contrasena.php'),
      body: {'email': emailCtrl.text.trim()},
    );

    print('Respuesta backend: ${res.body}');
    try {
      final data = jsonDecode(res.body);
      setState(() {
        mensaje = data['message'];
        cargando = false;
      });
    } catch (e) {
      setState(() {
        mensaje = "Error inesperado del servidor. Intenta más tarde.";
        cargando = false;
      });
      print("Error al decodificar JSON: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
                "Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña"),
            const SizedBox(height: 20),
            TextField(
              controller: emailCtrl,
              decoration:
                  const InputDecoration(labelText: "Correo electrónico"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: cargando ? null : recuperar,
              child: cargando
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text("Enviar enlace"),
            ),
            const SizedBox(height: 20),
            Text(
              mensaje,
              style: TextStyle(
                  color:
                      mensaje.contains("enviado") ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
