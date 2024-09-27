import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'perfil.dart';
import 'main.dart';
import 'selectedItemPainter.dart';
import 'providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'domicilio.dart';
import 'PQRS.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Domicilios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: {
        '/perfil': (context) => Perfil(), // Ruta hacia Perfil
        '/main': (context) => const RegisterPage(), // Ruta hacia Login
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _selectedEstado = 'Seleccione una opción';
  int _selectedIndex = 0;
  List<dynamic> _domicilios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDomicilios();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Perfil()),
      );
    }
  }

  void _logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

    AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        showCloseIcon: false,
        title: "Hasta Pronto",
        dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
        barrierColor: const Color.fromARGB(147, 26, 26, 26),
        desc: "Cerraste sesión correctamente.",
        headerAnimationLoop: true,
        btnOkOnPress: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const RegisterPage()),
            (Route<dynamic> route) => false,
          );
        },
        descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
        buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
        titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
    ).show();
}

void _fetchDomicilios() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final user = userProvider.user;

  setState(() {
    _isLoading = true; // Iniciar la carga
  });

  try {
    List<dynamic> domicilios = await obtenerDomicilios(_selectedEstado, user!.id);
    setState(() {
      _domicilios = domicilios;
      _isLoading = false; // Finalizar la carga
    });
  } catch (error) {
    setState(() {
      _isLoading = false; // Asegúrate de finalizar la carga en caso de error
    });
    print('Error al obtener domicilios: $error');
    // Puedes mostrar un mensaje de error en la UI si lo deseas
  }
}

Color _getColorByEstadoId(int estadoId) {
switch (estadoId) {
  case 3:
    return Colors.grey; // Pendiente
  case 6:
    return Colors.green; // Entregado
  case 8:
    return Colors.red; // Cancelado
  default:
    return Colors.black;
}
}

Color _getColorByNovedad(String novedad){
  if(novedad == ''){
    return Colors.red;
  }else{
    return Colors.green;
  }
}

void _showEditModal(BuildContext context, Map domicilio) {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEstado;
  final _novedadesController = TextEditingController();
  bool _isNovedadesValid = false;

  void _validateNovedades(String value) {
    _isNovedadesValid = value.length >= 10;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 470, // Ajusta la altura según sea necesario
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Text(
                  'Editar Domicilio #${domicilio['id']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedEstado,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    fillColor: Colors.grey.shade200,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 3, style: BorderStyle.solid, color: Colors.purple),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    filled: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: '6', child: Text('Entregado')),
                    DropdownMenuItem(value: '3', child: Text('Pendiente')),
                    DropdownMenuItem(value: '8', child: Text('Cancelado')),
                  ],
                  onChanged: (newValue) {
                    _selectedEstado = newValue;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona un estado';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _novedadesController,
                  maxLines: 5, // Esto convierte el campo en un área de texto
                  decoration: InputDecoration(
                    labelText: 'Novedades',
                    hintText: 'Escribe al menos 10 caracteres',
                    fillColor: Colors.grey.shade200,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 3, style: BorderStyle.solid, color: Colors.purple),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    filled: true,
                  ),
                  onChanged: _validateNovedades,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {

                    if (_formKey.currentState!.validate()) {
                      String novedad = _novedadesController.text;
                      String estadoString = _selectedEstado!;
                      int estadoId = int.parse(estadoString);
                      int domicilioId = domicilio['id'];
                      String apiUrl = 'https://modisteria-back-production.up.railway.app/api/domicilios/updateDomicilio/$domicilioId';

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String? token = prefs.getString('x-token');

                      try{
                          var response = await http.put(
                          Uri.parse(apiUrl),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            'x-token': token ?? '',
                          },
                          body: jsonEncode(<String, dynamic>{
                            'novedades': novedad,
                            'estadoId': estadoId,
                          }),
                        );

                        if(response.statusCode == 201){

                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.scale,
                            showCloseIcon: false,
                            title: "Correcto",
                            dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
                            barrierColor: const Color.fromARGB(147, 26, 26, 26),
                            desc: "El Domicilio se editó correctamente.",
                            headerAnimationLoop: true,
                            btnOkOnPress: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => MyHomePage()),
                              );
                            },
                            descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
                            buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
                            titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
                          ).show();

                        }else{
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
                                    "Error al editar el Domicilio",
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

                      }catch(e){
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

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Editar'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              user!.roleId == 4 ? 'Mis Domicilios': 'Mis Pedidos',
              style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset('assets/img/domicilio.png', fit: BoxFit.cover),
            ),
          ],
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: _logout,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _domicilios.length,
                    itemBuilder: (context, index) {
                      final domicilio = _domicilios[index];
                      final ventas = domicilio['ventas'];
                      final cotizacion = ventas['cotizacion'];
                      final cotizacionPedidos = cotizacion['cotizacion_pedidos'];

                      return Card(
                        child: ListTile(
                          title: Text(
                            'Domicilio #${domicilio['id']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                domicilio['novedades'] == ""
                                    ? 'Novedades: No hay novedades'
                                    : 'Novedades: ${domicilio['novedades']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getColorByNovedad(domicilio['novedades']),
                                ),
                              ),
                              Text(
                                domicilio['estadoId'] == 3
                                    ? 'Estado: Pendiente'
                                    : domicilio['estadoId'] == 6
                                        ? 'Estado: Entregado'
                                        : domicilio['estadoId'] == 8
                                            ? 'Estado: Cancelado'
                                            : 'Estado: Por entregar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getColorByEstadoId(domicilio['estadoId']),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (user.roleId == 4)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    ),
                                    onPressed: () {
                                      // Mostrar modal con información del pedido
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          elevation: 16,
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            height: 550,
                                            width: 500,
                                            child: Column(
                                              children: <Widget>[
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: IconButton(
                                                    icon: const Icon(Icons.close, color: Colors.black),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ),
                                                Text(
                                                  'Detalles del Pedido #${domicilio['id']}',
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                const Divider(),
                                                const SizedBox(height: 10),
                                                Expanded(
                                                  child: ListView.builder(
                                                    itemCount: cotizacionPedidos.length,
                                                    itemBuilder: (context, pedidoIndex) {
                                                      final pedido = cotizacionPedidos[pedidoIndex]['pedido'];
                                                      return Card(
                                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                                        elevation: 4,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: ListTile(
                                                          title: RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'Pedido ID: ',
                                                                      style: TextStyle(
                                                                        fontSize: 18,
                                                                        color: Colors.black,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${pedido['idPedido']}',
                                                                      style: const TextStyle(
                                                                        fontSize: 18,
                                                                        color: Color.fromARGB(255, 71, 71, 71),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                          subtitle: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const SizedBox(height: 5),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'Talla: ',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.purple, 
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${pedido['talla']}',
                                                                      style: const TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.black,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'Cantidad: ',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.purple, // Color para "Cantidad:"
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${pedido['cantidad']}',
                                                                      style: const TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.black, // Color para el valor de "Cantidad"
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'Usuario: ',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.purple, // Color para "Usuario:"
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${pedido['usuario']['nombre']}',
                                                                      style: const TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.black, // Color para el valor de "Usuario"
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                    },
                                    child: const Text('Pedido Info'),
                                  ),
                                  const Spacer(),

                                  if (user.roleId == 4)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onPressed: () {
                                        _showEditModal(context, domicilio);
                                      },
                                      child: const Icon(Icons.edit, size: 18),
                                    )
                                  else
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PQRSForm(domicilioId: domicilio['id']),
                                          ),
                                        );
                                      },
                                      child: const Icon(Icons.add_call, size: 18),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/img/domicilio.png'), color: Colors.black),
            label: 'Domicilios',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/img/imagePerfil.png'), color: Colors.black),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}