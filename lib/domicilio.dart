import 'package:http/http.dart' as http;
import 'dart:convert';

class Domicilio {
  int id;
  String direccion;
  String descripcion;
  int valorPrenda;
  int valorDomicilio;
  int valorPagar;
  String estado;
  String novedades;

  Domicilio({
    required this.id,
    required this.direccion,
    required this.descripcion,
    required this.valorPrenda,
    required this.valorDomicilio,
    required this.valorPagar,
    required this.estado,
    required this.novedades,
  });

  factory Domicilio.fromJson(Map<String, dynamic> json) {
    return Domicilio(
      id: json['id_domicilio'] ?? '',
      direccion: json['direccion'] ?? '',
      descripcion: json['descripcion'] ?? '',
      valorPrenda: (json['valorPrenda'] ?? 0).toInt(),
      valorDomicilio: (json['valorDomicilio'] ?? 0).toInt(),
      valorPagar: (json['valorPagar'] ?? 0).toInt(),
      estado: json['estado'] ?? '',
      novedades: json['novedades'] ?? '',
    );
  }
}

// Función para obtener la lista de domicilios
Future<List<Domicilio>> obtenerDomiciliosPorEstado(String estado) async {
  final response = await http.get(Uri.parse('https://api-domicilios.onrender.com/domicilios'));
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    print('Decoded JSON: $jsonData');

    List<Domicilio> domicilios = [];
    if (jsonData['data'] is List) {
      domicilios = (jsonData['data'] as List)
          .map((item) => Domicilio.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    print('Domicilios: $domicilios');

    if (estado == 'Seleccione una opción') {
      return domicilios;
    } else {
      return domicilios.where((domicilio) => domicilio.estado == estado).toList();
    }
  } else {
    throw Exception('Error al obtener los domicilios');
  }
}
