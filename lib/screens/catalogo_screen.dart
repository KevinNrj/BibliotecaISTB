import 'package:flutter/material.dart';
import '../models/libro_model.dart';
import '../services/api_service.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  List<Libro> libros = [];
  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> carreras = [];
  String? categoriaSeleccionada;
  String? carreraSeleccionada;
  String tituloBuscar = '';
  final tituloCtrl = TextEditingController();

  // Paleta de colores
  final Color fondoCrema = const Color(0xFFFFF2DF);
  final Color rojoInstitucional = const Color(0xFFD90B13);
  final Color rojoOscuro = const Color(0xFFA10A10);
  final Color textoPrincipal = const Color(0xFF5A3D3D);

  @override
  void initState() {
    super.initState();
    cargarFiltros();
    cargarLibros();
  }

  void cargarFiltros() async {
    categorias = await ApiService.obtenerCategorias();
    carreras = await ApiService.obtenerCarreras();
    setState(() {});
  }

  void cargarLibros() async {
    libros = await ApiService.obtenerLibros();
    setState(() {});
  }

  void cargarLibrosFiltrados() async {
    libros = await ApiService.obtenerLibrosFiltrados(
      categoria: categoriaSeleccionada,
      carrera: carreraSeleccionada,
      titulo: tituloBuscar,
    );
    setState(() {});
  }

  void limpiarFiltros() {
    setState(() {
      categoriaSeleccionada = null;
      carreraSeleccionada = null;
      tituloBuscar = '';
      tituloCtrl.clear();
    });
    cargarLibros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoCrema,
      appBar: AppBar(
        title: const Text("Catálogo Institucional"),
        backgroundColor: rojoInstitucional,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filtros en una fila adaptativa
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DropdownButtonFormField<String>(
                      value: categoriaSeleccionada,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.category,
                            color: Color(0xFFD90B13)),
                      ),
                      isExpanded: true,
                      items: categorias.map((cat) {
                        return DropdownMenuItem(
                          value: cat['Codigo_Categoria'].toString(),
                          child: Text(cat['Nombre_Categoria']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => categoriaSeleccionada = value);
                        cargarLibrosFiltrados();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: DropdownButtonFormField<String>(
                      value: carreraSeleccionada,
                      decoration: InputDecoration(
                        labelText: 'Carrera',
                        border: const OutlineInputBorder(),
                        prefixIcon:
                            const Icon(Icons.school, color: Color(0xFFD90B13)),
                      ),
                      isExpanded: true,
                      items: carreras.map((car) {
                        return DropdownMenuItem(
                          value: car['Codigo_Carrera'].toString(),
                          child: Text(car['Nombre_Carrera']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => carreraSeleccionada = value);
                        cargarLibrosFiltrados();
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Campo de búsqueda con iconos
            TextField(
              controller: tituloCtrl,
              decoration: InputDecoration(
                labelText: 'Buscar por título',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD90B13)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFD90B13)),
                  onPressed: () {
                    setState(() => tituloBuscar = tituloCtrl.text.trim());
                    cargarLibrosFiltrados();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Botón limpiar filtros mejorado
            ElevatedButton.icon(
              onPressed: limpiarFiltros,
              icon: const Icon(Icons.clear),
              label: const Text("Limpiar filtros"),
              style: ElevatedButton.styleFrom(
                backgroundColor: rojoOscuro,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),

            const SizedBox(height: 16),

            const Divider(),

            // Lista de libros
            Expanded(
              child: libros.isEmpty
                  ? Center(
                      child: Text(
                        'No hay libros disponibles',
                        style: TextStyle(
                          color: textoPrincipal.withOpacity(0.7),
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: libros.length,
                      itemBuilder: (_, index) {
                        final libro = libros[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.book,
                                color: Color(0xFFD90B13)),
                            title: Text(
                              libro.titulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              "${libro.editorial} (${libro.anio})",
                              style: TextStyle(color: textoPrincipal),
                            ),
                            trailing: Text(
                              libro.codigo,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: rojoOscuro,
                              ),
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
