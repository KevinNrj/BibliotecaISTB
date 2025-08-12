import 'package:flutter/material.dart';
import '../widgets/menu_drawer.dart';
import 'editar_prestamos_screen.dart';
import 'actualizar_usuario_screen.dart';
import 'reporte_usuarios_screen.dart';
import 'reporte_prestamos_screen.dart';
import 'prestamo_screen.dart';

class AdminScreen extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const AdminScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2DF),
      appBar: AppBar(
        title: const Text("Panel de Administración"),
        backgroundColor: const Color(0xFFD90B13),
        foregroundColor: Colors.white,
      ),
      drawer: MenuDrawer(usuario: usuario), // <-- Aquí pasa usuario sin const
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildAdminButton(
              context,
              label: "Registrar Préstamo",
              icon: Icons.assignment_turned_in_outlined,
              color: const Color(0xFFD90B13),
              destination: PrestamosScreen(userSession: usuario),
            ),
            _buildAdminButton(
              context,
              label: "Editar Préstamos",
              icon: Icons.book_outlined,
              color: const Color(0xFFD90B13),
              destination: const EditarPrestamosScreen(),
            ),
            _buildAdminButton(
              context,
              label: "Editar Usuarios",
              icon: Icons.group_outlined,
              color: const Color(0xFFD90B13),
              destination: const ActualizarUsuarioScreen(),
            ),
            _buildAdminButton(
              context,
              label: "Reporte Usuarios",
              icon: Icons.bar_chart_outlined,
              color: const Color(0xFFD90B13),
              destination: const ReporteUsuariosScreen(),
            ),
            _buildAdminButton(
              context,
              label: "Reporte Préstamos",
              icon: Icons.insert_chart_outlined,
              color: const Color(0xFFD90B13),
              destination: const ReportePrestamosScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget destination,
    required Color color,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 6,
        shadowColor: Colors.black38,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
