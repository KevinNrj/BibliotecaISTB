// ...importaciones iguales
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditarPrestamosScreen extends StatefulWidget {
  const EditarPrestamosScreen({super.key});

  @override
  State<EditarPrestamosScreen> createState() => _EditarPrestamosScreenState();
}

class _EditarPrestamosScreenState extends State<EditarPrestamosScreen> {
  final TextEditingController buscadorCtrl = TextEditingController();
  List<Map<String, dynamic>> prestamos = [];
  bool isLoading = false;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    buscadorCtrl.addListener(() {
      if (debounce?.isActive ?? false) debounce!.cancel();
      debounce = Timer(const Duration(milliseconds: 400), () {
        buscarPrestamos();
      });
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    buscadorCtrl.dispose();
    super.dispose();
  }

  Future<void> buscarPrestamos() async {
    setState(() => isLoading = true);
    final nombre = buscadorCtrl.text.trim();

    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['BACKEND_URL']}/buscar_prestamos.php"),
        body: {'nombre': nombre},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => prestamos = List<Map<String, dynamic>>.from(data));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al comunicarse con el servidor")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Respuesta inválida del servidor")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> guardarCambios(int index) async {
    final prestamo = prestamos[index];

    final codigo = prestamo['Codigo_Prestamo']?.toString() ?? '';
    final fecha = prestamo['FechaDevolucion_Prestamo']?.toString() ?? '';
    final hora = prestamo['HoraDevolucion_Prestamo']?.toString() ?? '';
    final dias = prestamo['NumeroDias_Prestamo']?.toString() ?? '0';
    final observacion = prestamo['Observacion_Prestamo']?.toString() ?? '';

    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['BACKEND_URL']}/actualizar_prestamo.php"),
        body: {
          'Codigo_Prestamo': codigo,
          'FechaDevolucion_Prestamo': fecha,
          'HoraDevolucion_Prestamo': hora,
          'NumeroDias_Prestamo': dias,
          'Observacion_Prestamo': observacion,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Cambios guardados exitosamente")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${data['error'] ?? 'Desconocido'}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar los cambios")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con el servidor: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2DF),
      appBar: AppBar(
        title: const Text("Editar Préstamos"),
        backgroundColor: const Color(0xFFD90B13),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: buscadorCtrl,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre, apellido o código',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : prestamos.isEmpty
                      ? const Text("No se encontraron préstamos.")
                      : ListView.builder(
                          itemCount: prestamos.length,
                          itemBuilder: (context, index) {
                            final p = prestamos[index];
                            final nombreCompleto =
                                "${p['Nombre_Usuario']} ${p['Apellido_Usuario']}";
                            final codigoUsuario = p['Codigo_Usuario'];
                            final observacion =
                                p['Observacion_Prestamo'] ?? 'Prestado';

                            final fechaEntrega = DateTime.tryParse(
                                p['FechaEntrega_Prestamo'] ?? '');
                            final fechaDevolucion = DateTime.tryParse(
                                p['FechaDevolucion_Prestamo'] ?? '');
                            int diasCalculados = 0;
                            if (fechaEntrega != null &&
                                fechaDevolucion != null) {
                              diasCalculados = fechaDevolucion
                                  .difference(fechaEntrega)
                                  .inDays;
                              prestamos[index]['NumeroDias_Prestamo'] =
                                  diasCalculados;
                            }

                            final estadoColor = (observacion == 'Devuelto')
                                ? Colors.green
                                : const Color(0xFFD90B13);

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "👤 $nombreCompleto ($codigoUsuario)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: estadoColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        "📄 Código préstamo: ${p['Codigo_Prestamo']}"),
                                    const SizedBox(height: 12),
                                    ListTile(
                                      leading: const Icon(Icons.calendar_today,
                                          color: Colors.blue),
                                      title: const Text("Fecha de devolución"),
                                      subtitle: Text(
                                        p['FechaDevolucion_Prestamo'] ??
                                            'Seleccionar fecha',
                                      ),
                                      onTap: () async {
                                        final initialDate =
                                            fechaEntrega ?? DateTime.now();

                                        final nuevaFecha = await showDatePicker(
                                          context: context,
                                          initialDate: initialDate,
                                          firstDate: initialDate,
                                          lastDate: DateTime(2100),
                                        );

                                        if (nuevaFecha != null) {
                                          setState(() {
                                            final formatted = nuevaFecha
                                                .toIso8601String()
                                                .split('T')[0];
                                            prestamos[index][
                                                    'FechaDevolucion_Prestamo'] =
                                                formatted;
                                            if (fechaEntrega != null) {
                                              prestamos[index]
                                                      ['NumeroDias_Prestamo'] =
                                                  nuevaFecha
                                                      .difference(fechaEntrega)
                                                      .inDays;
                                            }
                                          });
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.access_time,
                                          color: Colors.deepOrange),
                                      title: const Text("Hora de devolución"),
                                      subtitle: Text(
                                        p['HoraDevolucion_Prestamo'] ??
                                            'Seleccionar hora',
                                      ),
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          final hora = time.hour
                                              .toString()
                                              .padLeft(2, '0');
                                          final min = time.minute
                                              .toString()
                                              .padLeft(2, '0');
                                          setState(() {
                                            prestamos[index][
                                                    'HoraDevolucion_Prestamo'] =
                                                '$hora:$min';
                                          });
                                        }
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        "📅 Días entre entrega y devolución: $diasCalculados días",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: observacion,
                                      decoration: const InputDecoration(
                                        labelText: 'Observación',
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Prestado',
                                            child: Text('📕 Prestado')),
                                        DropdownMenuItem(
                                            value: 'Devuelto',
                                            child: Text('📗 Devuelto')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            prestamos[index]
                                                ['Observacion_Prestamo'] = val;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.save),
                                      label: const Text("Guardar cambios"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFD90B13),
                                        foregroundColor: Colors.white,
                                        minimumSize:
                                            const Size(double.infinity, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () => guardarCambios(index),
                                    ),
                                  ],
                                ),
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
