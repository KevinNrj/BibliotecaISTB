import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReporteUsuariosScreen extends StatefulWidget {
  const ReporteUsuariosScreen({super.key});

  @override
  State<ReporteUsuariosScreen> createState() => _ReporteUsuariosScreenState();
}

class _ReporteUsuariosScreenState extends State<ReporteUsuariosScreen> {
  String? rolSeleccionado;
  String? carreraSeleccionada;

  final List<DropdownMenuItem<String>> roles = const [
    DropdownMenuItem(value: '1', child: Text("Administrador")),
    DropdownMenuItem(value: '2', child: Text("Estudiante")),
    DropdownMenuItem(value: '3', child: Text("Docente")),
    DropdownMenuItem(value: '13', child: Text("Vinculación")),
  ];

  final List<DropdownMenuItem<String>> carreras = const [
    DropdownMenuItem(value: '1', child: Text("GTI")),
    DropdownMenuItem(value: '2', child: Text("Admin. Financiera")),
    DropdownMenuItem(value: '3', child: Text("Contabilidad")),
    DropdownMenuItem(value: '4', child: Text("Desarrollo de Software")),
    DropdownMenuItem(value: '5', child: Text("Marketing")),
    DropdownMenuItem(value: '6', child: Text("Redes y Telecomunicaciones")),
  ];

  Future<pw.Document> generarPDF() async {
    final pdf = pw.Document();

    final uri = Uri.parse("${dotenv.env['BACKEND_URL']}/reporte_usuarios.php")
        .replace(queryParameters: {
      if (rolSeleccionado != null) 'rol': rolSeleccionado!,
      if (carreraSeleccionada != null) 'carrera': carreraSeleccionada!,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200 && response.body.trim().startsWith('[')) {
      final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape, // ✅ Horizontal asegurado
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("📋 Reporte de Usuarios",
                  style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headers: [
                  'Código',
                  'Nombre',
                  'Apellido',
                  'Correo',
                  'Rol',
                  'Carrera',
                ],
                data: data
                    .map((u) => [
                          u['Codigo_Usuario'],
                          u['Nombre_Usuario'],
                          u['Apellido_Usuario'],
                          u['Email_Usuario'],
                          u['Nombre_Rol'] ?? u['Codigo_Rol'],
                          u['Nombre_Carrera'] ?? u['Codigo_Carrera'],
                        ])
                    .toList(),
              ),
            ],
          ),
        ),
      );
    }

    return pdf;
  }

  void limpiarFiltros() {
    setState(() {
      rolSeleccionado = null;
      carreraSeleccionada = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reporte de Usuarios")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: rolSeleccionado,
              decoration: const InputDecoration(labelText: "Rol"),
              items: roles,
              onChanged: (val) => setState(() => rolSeleccionado = val),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: carreraSeleccionada,
              decoration: const InputDecoration(labelText: "Carrera"),
              items: carreras,
              onChanged: (val) => setState(() => carreraSeleccionada = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generar PDF"),
              onPressed: () async {
                final pdf = await generarPDF();
                await Printing.layoutPdf(
                  onLayout: (format) => pdf.save(),
                  format: PdfPageFormat
                      .a4.landscape, // ✅ Forzar horizontal al imprimir
                );
                limpiarFiltros();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "✅ PDF generado en horizontal y filtros reiniciados"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
