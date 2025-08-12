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

  /// Método auxiliar para formato de fecha personalizado (dd/mm/yyyy)
  String get fechaFormateada {
    final partes = fechaPrestamo.split("-");
    if (partes.length != 3) return fechaPrestamo;
    return "${partes[2]}/${partes[1]}/${partes[0]}";
  }

  /// Método auxiliar para mostrar solo hora en formato HH:mm
  String get horaFormateada {
    return horaEntrega.length >= 5 ? horaEntrega.substring(0, 5) : horaEntrega;
  }

  /// Método opcional para estado visual
  bool get estaPrestado => observacion.toLowerCase() == "prestado";
}
