import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/libro_model.dart';
import '../models/prestamo_model.dart';

class ApiService {
  static final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';

  static Future<List<Libro>> obtenerLibros() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/listar_libros.php"));
      final List data = jsonDecode(res.body);
      return data.map((e) => Libro.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Error al obtener libros: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/listar_categorias.php"));
      final List data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception("Error al obtener categorías: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerCarreras() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/listar_carreras.php"));
      final List data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception("Error al obtener carreras: $e");
    }
  }

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

  static Future<String> crearPrestamo(
      String codigoUsuario, String codigoLibro) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/crear_prestamo.php"),
        body: {
          'codigo_usuario': codigoUsuario,
          'codigo_libro': codigoLibro,
        },
      );
      return res.body;
    } catch (e) {
      return "error: $e";
    }
  }

  static Future<List<Prestamo>> obtenerHistorial(String codigoUsuario) async {
    try {
      print('📤 Enviando código de usuario: $codigoUsuario');

      final res = await http.post(
        Uri.parse("$baseUrl/listar_prestamos_usuario.php"),
        body: {'codigo_usuario': codigoUsuario},
      );

      print('📥 Contenido de res.body: ${res.body}');

      if (!res.headers['content-type']!.contains('application/json')) {
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
}
