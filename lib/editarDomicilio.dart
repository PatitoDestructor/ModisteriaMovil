import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modisteria2/domicilio.dart';
import 'index.dart'; 
import 'selectedItemPainter.dart';
import 'perfil.dart';
import 'package:http/http.dart' as http;

class EditarDomicilio extends StatefulWidget {
  final Domicilio domicilio; // Recibo el domicilio como parámetro

  EditarDomicilio({required this.domicilio});

  @override
  _EditarDomicilioState createState() => _EditarDomicilioState();
}

class _EditarDomicilioState extends State<EditarDomicilio> {
  int _selectedIndex = 1;
  final TextEditingController _novedadController = TextEditingController();
  late String _selectedEstado; // Estado seleccionado

  @override
  void initState() {
    super.initState();
    _selectedEstado = widget.domicilio.estado;
    _novedadController.text = widget.domicilio.novedades ?? ''; // Inicializamos el controlador con la novedad existente
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Perfil()),
      );
    }
  }

  void _update(int id) async {
    String novedad = _novedadController.text.trim();
    String direccionEdit = widget.domicilio.direccion.toString();
    String descripcionEdit = widget.domicilio.descripcion.toString();
    String valorPrendaEdit = widget.domicilio.valorPrenda.toString();
    String valorDomicilioEdit = widget.domicilio.valorDomicilio.toString();
    String valorPagarEdit = widget.domicilio.valorPagar.toString();
    String estadoEdit = _selectedEstado; // Usamos el estado seleccionado
    String apiUrl = 'https://api-domicilios.onrender.com/domicilios/$id';
    
    try {
      var response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "direccion": direccionEdit,
          "descripcion": descripcionEdit,
          "valorPrenda": valorPrendaEdit,
          "valorDomicilio": valorDomicilioEdit,
          "valorPagar": valorPagarEdit,
          "estado": estadoEdit,
          "novedades": novedad
        }),
      );

      if (response.statusCode == 200) {
        // Éxito al editar
        var jsonResponse = jsonDecode(response.body);
        print('Respuesta del servidor: $jsonResponse');
              
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  "El domicilio se editó correctamente",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            duration: const Duration(milliseconds: 2000),
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),
            backgroundColor: const Color.fromARGB(255, 12, 195, 106),
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        // Manejo de error al editar
        print('Error al editar: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.indeterminate_check_box,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  "Hubo un error al editar el domicilio",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            duration: const Duration(milliseconds: 2000),
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),
            backgroundColor: const Color.fromARGB(255, 241, 10, 10),
          ),
        );
      }
    } catch (e) {
      // Manejo de error genérico
      print('Error al conectarse al servidor: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Error al conectar con el servidor.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 227, 255),
        title: Row(
          children: [
            const Text(
              'Editar Domicilio',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                'assets/img/imageDomicilio.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Información de Entrega',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              color: const Color.fromARGB(255, 255, 255, 255),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Dirección: ${widget.domicilio.direccion}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Descripción: ${widget.domicilio.descripcion}'),
                    const SizedBox(height: 8),
                    Text('Valor Prenda: ${widget.domicilio.valorPrenda}'),
                    const SizedBox(height: 8),
                    Text('Valor Domicilio: ${widget.domicilio.valorDomicilio}'),
                    const SizedBox(height: 8),
                    Text('Valor a Pagar: ${widget.domicilio.valorPagar}'),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Actualizar Estado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedEstado,
              items: <String>['Pendiente', 'Entregado', 'Cancelado']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEstado = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Estado',
                fillColor: Colors.grey.shade200,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 3, style: BorderStyle.solid, color: Colors.purple),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Novedades',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: _novedadController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Detalles adicionales',
                fillColor: Colors.grey.shade200,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 3, style: BorderStyle.solid, color: Colors.purple),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _update(widget.domicilio.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // Cambia el color del botón
                foregroundColor: Colors.white, // Color del texto del botón
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
