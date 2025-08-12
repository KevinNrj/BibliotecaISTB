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
  List<Prestamo> prestamos = [];
  String? codigoUsuario;
  int paginaActual = 0;
  static const int itemsPorPagina = 5;

  static const Color fondoCrema = Color(0xFFFFF2DF);
  static const Color rojoInstitucional = Color(0xFFD90B13);
  static const Color rojoOscuro = Color(0xFFA10A10);
  static const Color textoSubtitulo = Color(0xFF5A3D3D);

  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarCodigoUsuario();
  }

  void _cargarCodigoUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final codigo = prefs.getString('codigo_usuario');

    if (codigo != null && codigo.isNotEmpty) {
      setState(() {
        codigoUsuario = codigo;
      });
      await _cargarPrestamos();
    } else {
      setState(() {
        cargando = false;
        error = "⚠️ Código de usuario no encontrado";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Código de usuario no encontrado")),
      );
    }
  }

  Future<void> _cargarPrestamos() async {
    if (codigoUsuario == null) return;

    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final data = await ApiService.obtenerHistorial(codigoUsuario!);
      setState(() {
        prestamos = data;
        paginaActual = 0;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        error = "❌ Error al cargar historial.";
        cargando = false;
      });
    }
  }

  void _siguientePagina() {
    if ((paginaActual + 1) * itemsPorPagina < prestamos.length) {
      setState(() {
        paginaActual++;
      });
    }
  }

  void _paginaAnterior() {
    if (paginaActual > 0) {
      setState(() {
        paginaActual--;
      });
    }
  }

  List<Prestamo> get prestamosPaginaActual {
    final inicio = paginaActual * itemsPorPagina;
    final fin = inicio + itemsPorPagina;
    return prestamos.sublist(
      inicio,
      fin > prestamos.length ? prestamos.length : fin,
    );
  }

  Widget _buildEstadoChip(String estado) {
    Color bgColor;
    Color textColor = Colors.white;

    switch (estado.toLowerCase()) {
      case 'devuelto':
        bgColor = Colors.green.shade600;
        break;
      case 'pendiente':
        bgColor = Colors.orange.shade700;
        break;
      case 'atrasado':
        bgColor = Colors.red.shade700;
        break;
      default:
        bgColor = rojoInstitucional;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoCrema,
      appBar: AppBar(
        title: const Text('📖 Historial de Préstamos'),
        backgroundColor: rojoInstitucional,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: TextStyle(color: rojoOscuro, fontSize: 16),
                  ),
                )
              : prestamos.isEmpty
                  ? Center(
                      child: Text(
                        'No hay préstamos registrados.',
                        style:
                            TextStyle(color: rojoInstitucional, fontSize: 16),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: prestamosPaginaActual.length,
                            itemBuilder: (context, index) {
                              final p = prestamosPaginaActual[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor: rojoInstitucional
                                                .withOpacity(0.8),
                                            child: const Icon(Icons.book,
                                                color: Colors.white, size: 28),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              p.libroTitulo,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          _buildEstadoChip(p.observacion),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.code,
                                              size: 18, color: rojoOscuro),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Código: ${p.codigoLibro}',
                                            style: TextStyle(
                                                color: textoSubtitulo),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.date_range,
                                              size: 18, color: rojoOscuro),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Fecha: ${p.fechaPrestamo}',
                                            style: TextStyle(
                                                color: textoSubtitulo),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              size: 18, color: rojoOscuro),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Hora: ${p.horaEntrega}',
                                            style: TextStyle(
                                                color: textoSubtitulo),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Página ${paginaActual + 1} de ${((prestamos.length - 1) / itemsPorPagina).floor() + 1}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: rojoInstitucional),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios),
                                    color: paginaActual == 0
                                        ? Colors.grey
                                        : rojoInstitucional,
                                    onPressed: paginaActual == 0
                                        ? null
                                        : _paginaAnterior,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    color:
                                        (paginaActual + 1) * itemsPorPagina >=
                                                prestamos.length
                                            ? Colors.grey
                                            : rojoInstitucional,
                                    onPressed:
                                        (paginaActual + 1) * itemsPorPagina >=
                                                prestamos.length
                                            ? null
                                            : _siguientePagina,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
