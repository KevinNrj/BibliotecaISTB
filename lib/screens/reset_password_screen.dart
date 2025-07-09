import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final tokenCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String mensaje = '';
  bool cargando = false;
  bool visible1 = true;
  bool visible2 = true;

  Future<void> resetearPassword() async {
    setState(() {
      mensaje = '';
      cargando = true;
    });

    if (passCtrl.text.trim() != confirmCtrl.text.trim()) {
      setState(() {
        mensaje = '❌ Las contraseñas no coinciden';
        cargando = false;
      });
      return;
    }

    final res = await http.post(
      Uri.parse('${dotenv.env['BACKEND_URL']}/reset_password.php'),
      body: {
        'token': tokenCtrl.text.trim(),
        'password': passCtrl.text.trim(),
      },
    );

    final data = jsonDecode(res.body);
    setState(() {
      mensaje = data['message'];
      cargando = false;
    });

    if (data['success'] == true) {
      tokenCtrl.clear();
      passCtrl.clear();
      confirmCtrl.clear();
    }
  }

  @override
  void dispose() {
    tokenCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restablecer contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
                "Pega el token que recibiste por correo y define tu nueva contraseña."),
            const SizedBox(height: 20),
            TextField(
              controller: tokenCtrl,
              decoration:
                  const InputDecoration(labelText: "Token de recuperación"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: visible1,
              decoration: InputDecoration(
                labelText: "Nueva contraseña",
                suffixIcon: IconButton(
                  icon:
                      Icon(visible1 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => visible1 = !visible1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: visible2,
              decoration: InputDecoration(
                labelText: "Confirmar nueva contraseña",
                suffixIcon: IconButton(
                  icon:
                      Icon(visible2 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => visible2 = !visible2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: cargando ? null : resetearPassword,
              child: cargando
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text("Restablecer"),
            ),
            const SizedBox(height: 16),
            Text(mensaje,
                style: TextStyle(
                    color: mensaje.contains("✅") ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}
