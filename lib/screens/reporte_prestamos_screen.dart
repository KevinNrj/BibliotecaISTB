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
      queryParams['desde'] = fechaInicio!.toIso8601String().split('T').first;
      queryParams['hasta'] = fechaFin!.toIso8601String().split('T').first;
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
            pageFormat: PdfPageFormat.a4.landscape, // ✅ Forzar horizontal
            build: (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("📚 Reporte de Préstamos",
                    style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 12),
                pw.Text(
                  "Texto en cursiva",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                if (queryParams.isNotEmpty)
                  pw.Text(queryParams.toString(),
                      style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 12),
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
                ),
              ],
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
      appBar: AppBar(title: const Text("Reporte de Préstamos")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usuarioCtrl,
              decoration:
                  const InputDecoration(labelText: "Nombre del Usuario"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: estadoCtrl,
              decoration:
                  const InputDecoration(labelText: "Estado del préstamo"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(fechaInicio == null
                        ? "Fecha inicio"
                        : fechaInicio!.toLocal().toString().split(' ')[0]),
                    onPressed: () => seleccionarFecha(context, true),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(fechaFin == null
                        ? "Fecha fin"
                        : fechaFin!.toLocal().toString().split(' ')[0]),
                    onPressed: () => seleccionarFecha(context, false),
                  ),
                ),
              ],
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
