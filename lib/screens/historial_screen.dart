import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prestamo_model.dart';
import '../services/api_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  Future<List<Prestamo>>? _historialFuture;
  String? codigoUsuario;

  @override
  void initState() {
    super.initState();
    _cargarCodigoUsuario();
  }

  void _cargarCodigoUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final codigo = prefs.getString('codigo_usuario');

    if (codigo != null && codigo.isNotEmpty) {
      print('📥 Código cargado: $codigo');
      setState(() {
        codigoUsuario = codigo;
        _historialFuture = ApiService.obtenerHistorial(codigo);
      });
    } else {
      print('⚠️ Código de usuario no encontrado en SharedPreferences');
    }
  }

  Future<void> _recargar() async {
    if (codigoUsuario != null) {
      setState(() {
        _historialFuture = ApiService.obtenerHistorial(codigoUsuario!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📖 Historial de Préstamos')),
      body: _historialFuture == null
          ? const Center(child: Text('Cargando historial...'))
          : RefreshIndicator(
              onRefresh: _recargar,
              child: FutureBuilder<List<Prestamo>>(
                future: _historialFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error al cargar historial.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay préstamos registrados.'));
                  }

                  final prestamos = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: prestamos.length,
                    itemBuilder: (context, index) {
                      final p = prestamos[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          leading:
                              const Icon(Icons.bookmark, color: Colors.blue),
                          title: Text(
                            p.libroTitulo,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📘 Código del libro: ${p.codigoLibro}'),
                              Text('📅 Fecha: ${p.fechaPrestamo}'),
                              Text('⏰ Hora: ${p.horaEntrega}'),
                              Text('🔖 Estado: ${p.observacion}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
