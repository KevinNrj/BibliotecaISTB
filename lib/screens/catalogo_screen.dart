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
      appBar: AppBar(title: const Text("Catálogo")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: categoriaSeleccionada,
              hint: const Text("Filtrar por categoría"),
              onChanged: (value) {
                setState(() => categoriaSeleccionada = value);
                cargarLibrosFiltrados();
              },
              items: categorias.map((cat) {
                return DropdownMenuItem(
                  value: cat['Codigo_Categoria'].toString(),
                  child: Text(cat['Nombre_Categoria']),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: carreraSeleccionada,
              hint: const Text("Filtrar por carrera"),
              onChanged: (value) {
                setState(() => carreraSeleccionada = value);
                cargarLibrosFiltrados();
              },
              items: carreras.map((car) {
                return DropdownMenuItem(
                  value: car['Codigo_Carrera'].toString(),
                  child: Text(car['Nombre_Carrera']),
                );
              }).toList(),
            ),
            TextField(
              controller: tituloCtrl,
              decoration: InputDecoration(
                labelText: 'Buscar por título',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    setState(() => tituloBuscar = tituloCtrl.text.trim());
                    cargarLibrosFiltrados();
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: limpiarFiltros,
              icon: const Icon(Icons.clear),
              label: const Text("Limpiar filtros"),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: libros.length,
                itemBuilder: (_, index) {
                  final libro = libros[index];
                  return ListTile(
                    title: Text(libro.titulo),
                    subtitle: Text("${libro.editorial} (${libro.anio})"),
                    trailing: Text(libro.codigo),
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
