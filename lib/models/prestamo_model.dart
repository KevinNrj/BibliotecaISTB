class Prestamo {
  final String codigoLibro;
  final String libroTitulo;
  final String fechaPrestamo;
  final String horaEntrega;
  final String observacion;

  Prestamo({
    required this.codigoLibro,
    required this.libroTitulo,
    required this.fechaPrestamo,
    required this.horaEntrega,
    required this.observacion,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      codigoLibro: json['codigo_libro'] ?? '',
      libroTitulo: json['libro_titulo'] ?? '',
      fechaPrestamo: json['fecha_prestamo'] ?? '',
      horaEntrega: json['hora_entrega'] ?? '',
      observacion: json['observacion'] ?? '',
    );
  }
}
