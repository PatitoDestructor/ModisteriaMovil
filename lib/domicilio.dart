import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Función para obtener la lista de domicilios
Future<List<dynamic>> obtenerDomicilios(String estado, int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('x-token');
  String url;

  if(id == 4){
    url = "https://modisteria-back-production.up.railway.app/api/domicilios/getDomiciliosByDomiciliario/$id";
  }else{
    url = "https://modisteria-back-production.up.railway.app/api/domicilios/getDomiciliosByCliente/$id";
  }

  final response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-token': token ?? '', 
    },
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return jsonData; // Retorna los domicilios
  } else {
    print(response.statusCode);
    throw Exception('Error al obtener los domicilios');
  }
}
