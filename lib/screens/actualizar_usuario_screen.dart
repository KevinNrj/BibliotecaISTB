import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'editar_usuario_screen.dart'; // Import necesario

class ActualizarUsuarioScreen extends StatefulWidget {
  const ActualizarUsuarioScreen({super.key});

  @override
  State<ActualizarUsuarioScreen> createState() =>
      _ActualizarUsuarioScreenState();
}

class _ActualizarUsuarioScreenState extends State<ActualizarUsuarioScreen> {
  final TextEditingController buscadorCtrl = TextEditingController();
  List<Map<String, dynamic>> usuariosEncontrados = [];
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    buscadorCtrl.addListener(() {
      if (debounce?.isActive ?? false) debounce!.cancel();
      debounce = Timer(const Duration(milliseconds: 400), () {
        buscarUsuarios(buscadorCtrl.text);
      });
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    buscadorCtrl.dispose();
    super.dispose();
  }

  Future<void> buscarUsuarios(String termino) async {
    if (termino.trim().isEmpty) {
      setState(() => usuariosEncontrados = []);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['BACKEND_URL']}/buscar_usuario.php"),
        body: {'busqueda': termino},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() =>
              usuariosEncontrados = List<Map<String, dynamic>>.from(data));
        } else {
          setState(() => usuariosEncontrados = []);
        }
      } else {
        setState(() => usuariosEncontrados = []);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al comunicarse con el servidor")),
        );
      }
    } catch (e) {
      setState(() => usuariosEncontrados = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el backend")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Actualizar Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: buscadorCtrl,
              decoration: const InputDecoration(
                labelText: "Buscar por nombre, apellido o carrera",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: usuariosEncontrados.isEmpty
                  ? const Center(child: Text("🔎 No hay resultados"))
                  : ListView.builder(
                      itemCount: usuariosEncontrados.length,
                      itemBuilder: (context, index) {
                        final u = usuariosEncontrados[index];
                        final nombre =
                            "${u['Nombre_Usuario']} ${u['Apellido_Usuario']}";
                        final correo = u['Email_Usuario'];
                        final rol = u['Codigo_Rol'];
                        final carrera = u['Codigo_Carrera'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text("👤 $nombre"),
                            subtitle: Text(
                                "📧 $correo\n🎓 Carrera: $carrera | Rol: $rol"),
                            trailing: const Icon(Icons.edit),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditarUsuarioScreen(usuario: u),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
