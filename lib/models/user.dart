// lib/models/user.dart
class User {
  final int id;
  final String nombre;
  final String apellido;
  final String gmail;
  final String contrasena;

  User({required this.id, required this.nombre, required this.apellido, required this.gmail, required this.contrasena});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'gmail': gmail,
      'contrasena': contrasena
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      gmail: json['gmail'],
      contrasena: json['contrasena'],
    );
  }
}
