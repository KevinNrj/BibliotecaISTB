import 'package:flutter/material.dart';
import '../widgets/menu_drawer.dart';
import 'editar_prestamos_screen.dart';
import 'actualizar_usuario_screen.dart';
import 'reporte_usuarios_screen.dart';
import 'reporte_prestamos_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panel de Administración")),
      drawer: const MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.book),
              label: const Text("Editar Préstamos"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditarPrestamosScreen(),
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.group),
              label: const Text("Editar Usuarios"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ActualizarUsuarioScreen(),
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text("Reporte Usuarios"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReporteUsuariosScreen(),
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.insert_chart),
              label: const Text("Reporte Préstamos"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportePrestamosScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
