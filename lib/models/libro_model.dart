class Libro {
  final String codigo;
  final String titulo;
  final String editorial;
  final String anio;

  Libro({
    required this.codigo,
    required this.titulo,
    required this.editorial,
    required this.anio,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      codigo: json['Codigo_Libro'],
      titulo: json['Titulo_Libro'],
      editorial: json['Editorial_Libro'],
      anio: json['Anio_Libro'],
    );
  }
}
