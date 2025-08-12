import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/libro_model.dart';
import '../models/prestamo_model.dart';

class ApiService {
  static final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';

  // 📚 Obtener todos los libros
  static Future<List<Libro>> obtenerLibros() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/listar_libros.php"));
      final List data = jsonDecode(res.body);
      return data.map((e) => Libro.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Error al obtener libros: $e");
    }
  }

  // 🗂 Obtener todas las categorías
  static Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/listar_categorias.php"));
      final List data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception("Error al obtener categorías: $e");
    }
  }

  // 🎓 Obtener todas las carreras
  static Future<List<Map<String, dynamic>>> obtenerCarreras() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/listar_carreras.php"));
      final List data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception("Error al obtener carreras: $e");
    }
  }

  // 🔍 Filtrar libros por categoría, carrera o título
  static Future<List<Libro>> obtenerLibrosFiltrados({
    String? categoria,
    String? carrera,
    String? titulo,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/listar_libros_filtrados.php"),
        body: {
          if (categoria != null) 'categoria': categoria,
          if (carrera != null) 'carrera': carrera,
          if (titulo != null && titulo.isNotEmpty) 'titulo': titulo,
        },
      );

      final List data = jsonDecode(res.body);
      return data.map((e) => Libro.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Error al filtrar libros: $e");
    }
  }

  // 📝 Registrar préstamo
  static Future<Map<String, dynamic>> crearPrestamo(
    String codigoUsuario,
    String codigoLibro,
    String fechaEntrega,
    String horaEntrega,
  ) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/crear_prestamo.php"),
        body: {
          'codigo_usuario': codigoUsuario,
          'codigo_libro': codigoLibro,
          'fecha_entrega': fechaEntrega,
          'hora_entrega': horaEntrega,
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {
        "success": false,
        "message": "❌ Error de conexión: $e",
      };
    }
  }

  // 📖 Obtener historial de préstamos del usuario
  static Future<List<Prestamo>> obtenerHistorial(String codigoUsuario) async {
    try {
      print('📤 Enviando código de usuario: $codigoUsuario');

      final res = await http.post(
        Uri.parse("$baseUrl/listar_prestamos_usuario.php"),
        body: {'codigo_usuario': codigoUsuario},
      );

      final contentType = res.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception("⚠️ Respuesta no válida: el servidor no devolvió JSON");
      }

      final decoded = jsonDecode(res.body);
      final List data = decoded['prestamos'] ?? [];
      return data.map((e) => Prestamo.fromJson(e)).toList();
    } catch (e) {
      print("🛑 Error al obtener historial: $e");
      throw Exception("Error al cargar historial.");
    }
  }

  // 👤 Obtener datos del usuario por código
  static Future<Map<String, dynamic>?> obtenerDatosUsuario(
      String codigo) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/obtener_datos_usuario.php"),
        body: {'codigo_usuario': codigo},
      );

      final data = jsonDecode(res.body);
      if (data["error"] == false) {
        return {
          "nombre": data["nombre"],
          "apellido": data["apellido"],
          "carrera": data["carrera"],
          "rol": data["Codigo_Rol"],
        };
      } else {
        return null;
      }
    } catch (e) {
      print("🛑 Error al obtener usuario: $e");
      return null;
    }
  }
}
