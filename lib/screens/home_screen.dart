import 'package:flutter/material.dart';
import 'catalogo_screen.dart';
import 'prestamo_screen.dart';
import 'historial_screen.dart';
import '../widgets/menu_drawer.dart';

class HomeScreen extends StatelessWidget {
  final Map usuario;
  const HomeScreen({super.key, required this.usuario});

  String obtenerNombreRol(String codigoRol) {
    switch (codigoRol) {
      case '2':
        return 'Estudiante';
      case '3':
        return 'Docente';
      default:
        return 'Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String codigoUsuario = usuario['Codigo_Usuario'];
    final String nombre = usuario['Nombre_Usuario'];
    final String codigoRol = usuario['Codigo_Rol'] ?? '0';
    final String rolNombre = obtenerNombreRol(codigoRol);

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio")),
      drawer: const MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👋 Bienvenido $rolNombre, $nombre',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // 🎓 Estudiante y Docente
            ElevatedButton.icon(
              icon: const Icon(Icons.book),
              label: const Text("Ver catálogo"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CatalogoScreen()),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Registrar préstamo"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrestamoScreen(codigoUsuario: codigoUsuario),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text("Ver historial"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistorialScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
