import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportePrestamosScreen extends StatefulWidget {
  const ReportePrestamosScreen({super.key});

  @override
  State<ReportePrestamosScreen> createState() => _ReportePrestamosScreenState();
}

class _ReportePrestamosScreenState extends State<ReportePrestamosScreen> {
  final TextEditingController usuarioCtrl = TextEditingController();
  final TextEditingController estadoCtrl = TextEditingController();
  DateTime? fechaInicio;
  DateTime? fechaFin;

  Future<pw.Document> generarPDF() async {
    final pdf = pw.Document();

    final Map<String, String> queryParams = {};
    if (usuarioCtrl.text.isNotEmpty) {
      queryParams['usuario'] = usuarioCtrl.text.trim();
    }
    if (estadoCtrl.text.isNotEmpty) {
      queryParams['estado'] = estadoCtrl.text.trim();
    }
    if (fechaInicio != null && fechaFin != null) {
      queryParams['desde'] = fechaInicio!.toIso8601String().split('T')[0];
      queryParams['hasta'] = fechaFin!.toIso8601String().split('T')[0];
    }

    final uri = Uri.parse("${dotenv.env['BACKEND_URL']}/reporte_prestamos.php")
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = response.body;
      if (body.trim().startsWith('[')) {
        final data = List<Map<String, dynamic>>.from(jsonDecode(body));

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (pw.Context context) => pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text("📚 Reporte de Préstamos",
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        )),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "Filtros aplicados:",
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.Text(queryParams.toString(),
                      style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 16),
                  pw.Table.fromTextArray(
                    headers: [
                      'Código',
                      'Usuario',
                      'Libro',
                      'Entrega',
                      'Devolución',
                      'Estado'
                    ],
                    data: data
                        .map((p) => [
                              p['Codigo_Prestamo'],
                              p['Nombre_Usuario'],
                              p['Titulo_Libro'],
                              "${p['FechaEntrega_Prestamo']} ${p['HoraEntrega_Prestamo']}",
                              "${p['FechaDevolucion_Prestamo']} ${p['HoraDevolucion_Prestamo']}",
                              p['Observacion_Prestamo'],
                            ])
                        .toList(),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellAlignment: pw.Alignment.centerLeft,
                    columnWidths: {
                      0: const pw.FixedColumnWidth(50),
                      1: const pw.FixedColumnWidth(80),
                      2: const pw.FlexColumnWidth(),
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return pdf;
  }

  Future<void> seleccionarFecha(BuildContext context, bool esInicio) async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) {
      setState(() {
        if (esInicio) {
          fechaInicio = seleccionada;
        } else {
          fechaFin = seleccionada;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2DF), // Fondo crema
      appBar: AppBar(
        title: const Text("Reporte de Préstamos"),
        backgroundColor: const Color(0xFFD90B13),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usuarioCtrl,
              decoration: InputDecoration(
                labelText: "Nombre del Usuario",
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: estadoCtrl,
              decoration: InputDecoration(
                labelText: "Estado del préstamo",
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      fechaInicio == null
                          ? "Fecha inicio"
                          : fechaInicio!.toLocal().toString().split(' ')[0],
                      style: const TextStyle(color: Colors.black),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => seleccionarFecha(context, true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      fechaFin == null
                          ? "Fecha fin"
                          : fechaFin!.toLocal().toString().split(' ')[0],
                      style: const TextStyle(color: Colors.black),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => seleccionarFecha(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generar PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD90B13),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final pdf = await generarPDF();
                await Printing.layoutPdf(
                  onLayout: (format) => pdf.save(),
                  format: PdfPageFormat.a4.landscape,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
