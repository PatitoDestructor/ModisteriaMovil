// lib/models/user.dart
class User {
  final int id;
  final String nombre;
  final String email;
  final String telefono;
  final String password;
  final int roleId;

  User({required this.id, required this.nombre, required this.email, required this.telefono, required this.password, required this.roleId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'password': password,
      'roleId': roleId
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      password: json['password'],
      roleId: json['roleId'],
    );
  }
}
