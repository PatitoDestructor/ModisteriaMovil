// lib/models/user.dart
class User {
  final int id;
  final String nombre;
  final String email;
  final String telefono;
  final String password;
  final String? direccion; // Permitir que sea nulo
  final int roleId;

  User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.password,
    this.direccion, // Permitir que sea nulo
    required this.roleId,
  });

  // Método para convertir el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'password': password,
      'direccion': direccion ?? '', // Si es nulo, poner una cadena vacía
      'roleId': roleId,
    };
  }

  // Método para crear un objeto User a partir de un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      password: json['password'],
      direccion: json['direccion'] == null ? null : json['direccion'], // Permitir null
      roleId: json['roleId'],
    );
  }
}
