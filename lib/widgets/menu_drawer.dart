import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/historial_screen.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  Future<void> cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('codigo_usuario');
    print('🚪 Sesión cerrada: código eliminado');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Bienvenido'),
            accountEmail: Text('Usuario activo'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.black87),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial de Préstamos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistorialScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Cerrar Sesión'),
            onTap: () => cerrarSesion(context),
          ),
        ],
      ),
    );
  }
}
