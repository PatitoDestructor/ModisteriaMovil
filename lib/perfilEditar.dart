import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';
import 'main.dart';
import 'perfil.dart';
import 'selectedItemPainter.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({Key? key}) : super(key: key);

  @override
  _EditarPerfilState createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  int _selectedIndex = 1;

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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  void _mostrarFormularioEditar() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        int id = user.id;
        _nombreController.text = user.nombre;
        _telefonoController.text = user.telefono;

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Editar Información',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ingrese su nombre',
                    hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                    fillColor: Colors.grey.shade200,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 3,
                        style: BorderStyle.solid,
                        color: Colors.purple,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El nombre es necesario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    hintText: 'Ingrese su teléfono',
                    hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                    fillColor: Colors.grey.shade200,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 3,
                        style: BorderStyle.solid,
                        color: Colors.purple,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El teléfono es necesario';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _editar(id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Editar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editar(int id) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null) {
      String nombre = _nombreController.text.trim();
      String telefono = _telefonoController.text.trim();

      // Obtener el token almacenado en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-token');

      String apiUrl =
          'https://modisteria-back-production.up.railway.app/api/usuarios/updateInfo/$id';

      try {
        var response = await http.put(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-token': token ?? '',
          },
          body: jsonEncode(<String, String>{
            "nombre": nombre,
            "telefono": telefono,
          }),
        );

        if (response.statusCode == 201) {
          var jsonResponse = jsonDecode(response.body);
          print('Respuesta del servidor: $jsonResponse');

          // Mostrar mensaje de éxito
          AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.scale,
              showCloseIcon: false,
              title: "Correcto",
              dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
              barrierColor: const Color.fromARGB(147, 26, 26, 26),
              desc: "Tu Información se actualizó Correctamente.",
              headerAnimationLoop: true,
              btnOkOnPress: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Perfil()),
                );
              },
              descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
              buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
              titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
          ).show();

          if (jsonResponse['token'] != null) {
            await prefs.setString('x-token', jsonResponse['token']);
          }
        } else {
          print('Error al editar: ${response.statusCode}');
          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.indeterminate_check_box, color: Colors.white),
                  SizedBox(width: 5),
                  Text("Hubo un error al editar la información.",
                      style: TextStyle(color: Colors.white)),
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
        print('Error al conectarse al servidor: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Error al conectar con el servidor.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
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
  }


  @override
  Widget build(BuildContext context) {
    
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    
    return Scaffold(

      backgroundColor: const Color.fromARGB(255, 246, 227, 255), 
      body: Center(
        child: user != null ?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Perfil de ${user.nombre}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              user.roleId == 1 ? 'Información detallada del Administrador' : user.roleId == 2 ? 'Información detallada del Cliente' : 'Información detallada del Domiciliario',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color.fromARGB(255, 255, 255, 255),
              margin: const EdgeInsets.all(30),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '¿Esta seguro de editar su información?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            'Regresar',
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
                          onPressed: _mostrarFormularioEditar,
                          child: const Text(
                            'Editar',
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
              ),
            ),
          ],
        ): const CircularProgressIndicator(),
      ),
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/img/domicilio.png')),
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
