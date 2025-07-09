import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PrestamoScreen extends StatefulWidget {
  final String codigoUsuario;
  const PrestamoScreen({super.key, required this.codigoUsuario});

  @override
  State<PrestamoScreen> createState() => _PrestamoScreenState();
}

class _PrestamoScreenState extends State<PrestamoScreen> {
  final TextEditingController codigoLibroCtrl = TextEditingController();
  String mensaje = "";
  bool isLoading = false;

  void registrar() async {
    final codigoLibro = codigoLibroCtrl.text.trim();

    if (codigoLibro.isEmpty) {
      setState(() => mensaje = "⚠️ Ingresa el código del libro");
      return;
    }

    setState(() => isLoading = true);

    final respuesta = await ApiService.crearPrestamo(
      widget.codigoUsuario,
      codigoLibro,
    );

    setState(() {
      isLoading = false;
      if (respuesta.trim() == "ok") {
        mensaje = "✅ Préstamo registrado correctamente";
        codigoLibroCtrl.clear();
      } else {
        mensaje = "❌ No se pudo registrar el préstamo: $respuesta";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar préstamo")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: codigoLibroCtrl,
              decoration: const InputDecoration(labelText: "Código del libro"),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: registrar,
                    child: const Text("Guardar préstamo"),
                  ),
            const SizedBox(height: 20),
            Text(mensaje, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
