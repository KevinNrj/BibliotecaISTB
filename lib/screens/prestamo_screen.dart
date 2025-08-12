import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class PrestamosScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;

  const PrestamosScreen({super.key, required this.userSession});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  final codigoUsuarioCtrl = TextEditingController();
  final codigoLibroCtrl = TextEditingController();

  Map<String, dynamic>? datosUsuario;
  Map<String, dynamic>? datosLibro;
  DateTime? fechaEntrega;

  bool buscandoUsuario = false;
  bool buscandoLibro = false;

  Future<void> buscarUsuario() async {
    final codigo = codigoUsuarioCtrl.text.trim();
    if (codigo.isEmpty) return;

    setState(() {
      buscandoUsuario = true;
      datosUsuario = null;
    });

    final response = await http.post(
      Uri.parse("${dotenv.env['BACKEND_URL']}/buscar_usuario_por_codigo.php"),
      body: {'codigo': codigo},
    );

    setState(() => buscandoUsuario = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['Codigo_Usuario'] != null) {
        setState(() => datosUsuario = data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Usuario no encontrado")),
        );
      }
    }
  }

  Future<void> buscarLibro() async {
    final codigo = codigoLibroCtrl.text.trim();
    if (codigo.isEmpty) return;

    setState(() {
      buscandoLibro = true;
      datosLibro = null;
    });

    final response = await http.post(
      Uri.parse("${dotenv.env['BACKEND_URL']}/buscar_libro_por_codigo.php"),
      body: {'codigo': codigo},
    );

    setState(() => buscandoLibro = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['Codigo_Libro'] != null) {
        setState(() => datosLibro = data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Libro no encontrado")),
        );
      }
    }
  }

  Future<void> seleccionarFechaHoraEntrega() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          fechaEntrega = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> registrarPrestamo() async {
    if (datosUsuario == null || datosLibro == null || fechaEntrega == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Debes completar todos los campos")),
      );
      return;
    }

    final fecha = fechaEntrega!;
    final fechaText =
        "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
    final horaText =
        "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}:00";

    final response = await http.post(
      Uri.parse("${dotenv.env['BACKEND_URL']}/registrar_prestamo.php"),
      body: {
        'codigo_usuario': datosUsuario!['Codigo_Usuario'],
        'codigo_libro': datosLibro!['Codigo_Libro'],
        'fecha_entrega': fechaText,
        'hora_entrega': horaText,
      },
    );

    final result = jsonDecode(response.body);
    final success = result['success'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? "Resultado desconocido")),
    );

    if (success) {
      setState(() {
        datosUsuario = null;
        datosLibro = null;
        fechaEntrega = null;
      });
      codigoUsuarioCtrl.clear();
      codigoLibroCtrl.clear();
    }
  }

  @override
  void dispose() {
    codigoUsuarioCtrl.dispose();
    codigoLibroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rol = widget.userSession['Codigo_Rol']?.toString();

    if (rol != '1') {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF2DF),
        appBar: AppBar(
          title: const Text("Préstamos"),
          backgroundColor: const Color(0xFFD90B13),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "🚫 Solo administradores pueden registrar préstamos.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF2DF),
      appBar: AppBar(
        title: const Text("Registrar Préstamo"),
        backgroundColor: const Color(0xFFD90B13),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildInputField(
              controller: codigoUsuarioCtrl,
              label: "Código del Usuario",
              icon: Icons.person_search,
              onTapIcon: buscarUsuario,
              onSubmitted: (_) => buscarUsuario(),
            ),
            if (buscandoUsuario)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (datosUsuario != null)
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.black),
                  title: Text(
                    "${datosUsuario!['Nombre_Usuario']} ${datosUsuario!['Apellido_Usuario']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text("🎓 Carrera: ${datosUsuario!['Nombre_Carrera']}"),
                ),
              ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: codigoLibroCtrl,
              label: "Código del Libro",
              icon: Icons.menu_book,
              onTapIcon: buscarLibro,
              onSubmitted: (_) => buscarLibro(),
            ),
            if (buscandoLibro)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (datosLibro != null)
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.library_books, color: Colors.black),
                  title: Text(
                    datosLibro!['Titulo_Libro'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text("📚 Categoría: ${datosLibro!['Nombre_Categoria']}"),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                fechaEntrega == null
                    ? "Seleccionar Fecha y Hora de Entrega"
                    : "Entrega: ${fechaEntrega!.toLocal().toString().substring(0, 16)}",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD90B13),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: seleccionarFechaHoraEntrega,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Registrar Préstamo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: registrarPrestamo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTapIcon,
    void Function(String)? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: onTapIcon,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
