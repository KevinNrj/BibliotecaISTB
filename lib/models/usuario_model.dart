class Usuario {
  final String codigo;
  final String nombre;
  final String email;
  final String rol;

  Usuario({
    required this.codigo,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      codigo: json['Codigo_Usuario'],
      nombre: '${json['Nombre_Usuario']} ${json['Apellido_Usuario']}',
      email: json['Email_Usuario'],
      rol: json['Codigo_Rol'].toString(),
    );
  }
}
