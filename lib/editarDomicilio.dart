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
      backgroundColor: const Color.fromARGB(255, 246, 227, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 227, 255),
        title: Row(
          children: [
            const Text(
              'Mis Domicilios',
              style: TextStyle(fontSize: 35),
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
        child: Center(
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'EDITAR',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color.fromARGB(255, 255, 255, 255),
                margin: const EdgeInsets.all(30),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Información de entrega',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dirección: ${widget.domicilio.direccion}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${widget.domicilio.descripcion}'),
                                Text('Valor Prenda: ${widget.domicilio.valorPrenda}'),
                                Row(
                                  children: <Widget>[
                                    Text('Valor Domicilio: ${widget.domicilio.valorDomicilio}'),
                                  ],
                                ),
                                Text('Valor a Pagar: ${widget.domicilio.valorPagar}'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
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
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Agregar novedad',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _novedadController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: widget.domicilio.novedades?.isEmpty ?? true 
                                ? 'Escriba la novedad' 
                                : widget.domicilio.novedades,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(
                              height:
                                  10), // Espacio entre la tarjeta y los botones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.black),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cerrar',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.black),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                onPressed: () {
                                  _update(widget.domicilio.id);
                                },
                                child: const Text(
                                  'Aceptar',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/img/imageDomicilio.png')),
                label: 'Domicilios',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/img/imagePerfil.png')),
                label: 'Perfil',
              ),
            ],
            currentIndex: _selectedIndex,
            backgroundColor: const Color.fromARGB(255, 246, 227, 255),
            selectedItemColor: Colors.black,
            onTap: _onItemTapped,
          ),
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 2),
            painter: SelectedItemPainter(
              selectedIndex: _selectedIndex,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
