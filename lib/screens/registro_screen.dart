import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final cedulaCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final codigoAccesoCtrl = TextEditingController();

  String rol = '2';
  String carrera = '1';
  String mensaje = '';
  bool cargando = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool cedulaValida(String cedula) {
    if (cedula.length != 10 || int.tryParse(cedula) == null) return false;

    final provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) return false;

    final digitoVerificador = int.parse(cedula[9]);
    final coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;

    for (int i = 0; i < 9; i++) {
      int valor = int.parse(cedula[i]) * coeficientes[i];
      suma += valor > 9 ? valor - 9 : valor;
    }

    final resultado = suma % 10 == 0 ? 0 : 10 - (suma % 10);
    return resultado == digitoVerificador;
  }

  Future<void> registrarUsuario() async {
    setState(() {
      mensaje = '';
      cargando = true;
    });

    final cedula = cedulaCtrl.text.trim();

    if (!cedulaValida(cedula)) {
      setState(() {
        mensaje = "❌ Cédula inválida";
        cargando = false;
      });
      return;
    }

    if ((rol == '1' || rol == '13') &&
        codigoAccesoCtrl.text.trim() != 'ISTB1948') {
      setState(() {
        mensaje = "🔐 Código de acceso incorrecto para el rol seleccionado";
        cargando = false;
      });
      return;
    }

    if (passCtrl.text.trim() != confirmPassCtrl.text.trim()) {
      setState(() {
        mensaje = "❌ Las contraseñas no coinciden";
        cargando = false;
      });
      return;
    }

    if (cedula.isEmpty ||
        nombreCtrl.text.trim().isEmpty ||
        apellidoCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        passCtrl.text.trim().isEmpty) {
      setState(() {
        mensaje = "⚠️ Por favor llena todos los campos";
        cargando = false;
      });
      return;
    }

    try {
      final res = await http.post(
        Uri.parse("${dotenv.env['BACKEND_URL']}/registrar_usuario.php"),
        body: {
          'codigo_usuario': cedula,
          'nombre': nombreCtrl.text.trim(),
          'apellido': apellidoCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'password': passCtrl.text.trim(),
          'rol': rol,
          'carrera': carrera,
          'codigo_acceso': codigoAccesoCtrl.text.trim(),
        },
      );

      final data = jsonDecode(res.body);
      setState(() {
        mensaje = data['success'] == true
            ? "✅ ${data['message']}"
            : "❌ ${data['message']}";
        cargando = false;
      });

      if (data['success'] == true) {
        cedulaCtrl.clear();
        nombreCtrl.clear();
        apellidoCtrl.clear();
        emailCtrl.clear();
        passCtrl.clear();
        confirmPassCtrl.clear();
        codigoAccesoCtrl.clear();
      }
    } catch (e) {
      setState(() {
        mensaje = "❌ Error de conexión: $e";
        cargando = false;
      });
    }
  }

  @override
  void dispose() {
    cedulaCtrl.dispose();
    nombreCtrl.dispose();
    apellidoCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    codigoAccesoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requiereCodigo = rol == '1' || rol == '13';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF2DF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD90B13),
        foregroundColor: Colors.white,
        title: const Text("Registro de Usuario"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextField(
                  controller: cedulaCtrl,
                  label: "Cédula",
                  icon: Icons.badge,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  controller: nombreCtrl,
                  label: "Nombres",
                  icon: Icons.person,
                ),
                _buildTextField(
                  controller: apellidoCtrl,
                  label: "Apellidos",
                  icon: Icons.person_outline,
                ),
                _buildTextField(
                  controller: emailCtrl,
                  label: "Correo electrónico",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildPasswordField(passCtrl, "Contraseña", _obscurePassword,
                    () => setState(() => _obscurePassword = !_obscurePassword)),
                const SizedBox(height: 12),
                _buildPasswordField(
                    confirmPassCtrl,
                    "Confirmar contraseña",
                    _obscureConfirmPassword,
                    () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: rol,
                  decoration: const InputDecoration(
                    labelText: "Rol",
                    prefixIcon: Icon(Icons.person_pin),
                  ),
                  onChanged: (value) => setState(() => rol = value!),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text("Administrador")),
                    DropdownMenuItem(value: '2', child: Text("Estudiante")),
                    DropdownMenuItem(value: '3', child: Text("Docente")),
                    DropdownMenuItem(value: '13', child: Text("Vinculación")),
                  ],
                ),
                if (requiereCodigo)
                  _buildTextField(
                    controller: codigoAccesoCtrl,
                    label: "Código de autorización",
                    icon: Icons.lock,
                  ),
                DropdownButtonFormField<String>(
                  value: carrera,
                  decoration: const InputDecoration(
                    labelText: "Carrera",
                    prefixIcon: Icon(Icons.school),
                  ),
                  onChanged: rol == '2'
                      ? (value) => setState(() => carrera = value!)
                      : null,
                  items: const [
                    DropdownMenuItem(
                        value: '1', child: Text("TECNOLOGÍA EN TI")),
                    DropdownMenuItem(
                        value: '2', child: Text("ADMINISTRACIÓN FINANCIERA")),
                    DropdownMenuItem(value: '3', child: Text("CONTABILIDAD")),
                    DropdownMenuItem(
                        value: '4', child: Text("DESARROLLO DE SOFTWARE")),
                    DropdownMenuItem(value: '5', child: Text("MARKETING")),
                    DropdownMenuItem(
                        value: '6', child: Text("REDES Y TELECOMUNICACIONES")),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Registrar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD90B13),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: cargando ? null : registrarUsuario,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  mensaje,
                  style: TextStyle(
                    color: mensaje.contains("✅") ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscureText, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
