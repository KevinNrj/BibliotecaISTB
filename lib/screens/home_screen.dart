import 'package:flutter/material.dart';
import 'catalogo_screen.dart';
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

  String obtenerEmojiRol(String codigoRol) {
    switch (codigoRol) {
      case '2':
        return '🎓';
      case '3':
        return '👩‍🏫';
      default:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = usuario['Nombre_Usuario'] ?? 'Invitado';
    final String codigoRol = usuario['Codigo_Rol'] ?? '0';
    final String rolNombre = obtenerNombreRol(codigoRol);
    final String emojiRol = obtenerEmojiRol(codigoRol);

    const fondoCrema = Color(0xFFFFF2DF);
    const rojoInstitucional = Color(0xFFD90B13);
    const rojoOscuro = Color(0xFFA10A10);
    const textoSubtitulo = Color(0xFF5A3D3D);

    return Scaffold(
      backgroundColor: fondoCrema,
      appBar: AppBar(
        title: const Text("Inicio"),
        backgroundColor: rojoInstitucional,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      drawer: MenuDrawer(usuario: usuario), // <-- Aquí pasa usuario sin const
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: rojoInstitucional,
                  radius: 28,
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$emojiRol Hola, $nombre!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: rojoInstitucional,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bienvenido de nuevo, $rolNombre.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: textoSubtitulo,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.library_books_outlined, size: 28),
              label: const Text("Explorar Catálogo",
                  style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: rojoOscuro,
                foregroundColor: Colors.white, // Texto e icono en blanco
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: rojoOscuro.withOpacity(0.7),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CatalogoScreen()),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.history_edu_outlined, size: 28),
              label: const Text("Historial de Préstamos",
                  style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: rojoOscuro,
                foregroundColor: Colors.white, // Texto e icono en blanco
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: rojoOscuro.withOpacity(0.7),
              ),
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
