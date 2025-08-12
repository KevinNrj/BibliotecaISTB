import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/historial_screen.dart';

class MenuDrawer extends StatelessWidget {
  final Map usuario;

  const MenuDrawer({super.key, required this.usuario});

  Future<void> cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('codigo_usuario');
    print('🚪 Sesión cerrada: código eliminado');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  bool mostrarHistorial() {
    final rol = usuario['Codigo_Rol']?.toString() ?? '';
    // Oculta historial para administrador ('1') y vinculación ('13')
    return rol != '1' && rol != '13';
  }

  String obtenerNombreRol(String codigoRol) {
    switch (codigoRol) {
      case '1':
        return 'Administrador';
      case '2':
        return 'Estudiante';
      case '3':
        return 'Docente';
      case '13':
        return 'Vinculación';
      default:
        return 'Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    const fondoCrema = Color(0xFFFFF2DF);
    const rojoInstitucional = Color(0xFFD90B13);
    const rojoOscuro = Color(0xFFA10A10);
    const textoSubtitulo = Color(0xFF5A3D3D);

    final codigoRol = usuario['Codigo_Rol']?.toString() ?? '';
    final nombreRol = obtenerNombreRol(codigoRol);

    return Drawer(
      child: Container(
        color: fondoCrema,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: rojoInstitucional,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(40)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      usuario['Nombre_Usuario'] != null &&
                              usuario['Nombre_Usuario'].toString().isNotEmpty
                          ? usuario['Nombre_Usuario'][0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Color(0xFFD90B13),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario['Nombre_Usuario'] ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nombreRol,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (mostrarHistorial())
                    ListTile(
                      leading: Icon(Icons.history, color: rojoInstitucional),
                      title: const Text('Historial de Préstamos'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistorialScreen(),
                          ),
                        );
                      },
                      hoverColor: rojoInstitucional.withOpacity(0.1),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  const Divider(thickness: 1),
                  ListTile(
                    leading: Icon(Icons.logout, color: rojoOscuro),
                    title: Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: rojoOscuro),
                    ),
                    onTap: () => cerrarSesion(context),
                    hoverColor: rojoOscuro.withOpacity(0.1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Biblioteca ISTB © 2025',
                style: TextStyle(
                  color: textoSubtitulo,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
