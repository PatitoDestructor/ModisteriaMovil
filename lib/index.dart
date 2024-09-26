import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'perfil.dart';
import 'main.dart';
import 'selectedItemPainter.dart';
import 'providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'domicilio.dart';
import 'PQRS.dart';

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
        '/main': (context) => RegisterPage(), // Ruta hacia Login
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedEstado = 'Seleccione una opción';
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
              "Sesión cerrada correctamente",
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        duration: const Duration(seconds: 2),
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 195, 106),
      ),
    );

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => RegisterPage()),
    (Route<dynamic> route) => false,
  );
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
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.black),
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
              ? const Center(child: CircularProgressIndicator()) // Muestra un indicador de carga mientras se cargan los datos
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
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                            padding: EdgeInsets.all(20),
                                            height: 550, // Ajusta la altura según sea necesario
                                            width: 500,
                                            child: Column(
                                              children: <Widget>[
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: IconButton(
                                                    icon: Icon(Icons.close, color: Colors.black),
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
                                                SizedBox(height: 10),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Expanded(
                                                  child: ListView.builder(
                                                    itemCount: cotizacionPedidos.length,
                                                    itemBuilder: (context, pedidoIndex) {
                                                      final pedido = cotizacionPedidos[pedidoIndex]['pedido'];
                                                      return Card(
                                                        margin: EdgeInsets.symmetric(vertical: 8),
                                                        elevation: 4,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: ListTile(
                                                          title: Text(
                                                            'Pedido ID: ${pedido['idPedido']}',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          subtitle: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(height: 5),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text: 'Talla: ',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.purple, // Color para "Talla:"
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${pedido['talla']}',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.black, // Color para el valor de "Talla"
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text: 'Cantidad: ',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.purple, // Color para "Cantidad:"
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${pedido['cantidad']}',
                                                                      style: TextStyle(
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
                                                                    TextSpan(
                                                                      text: 'Usuario: ',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.purple, // Color para "Usuario:"
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${pedido['usuario']['nombre']}',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.black, // Color para el valor de "Usuario"
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(height: 5),
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
                                  Spacer(),

                                  if (user.roleId == 4) // Muestra el botón "Editar" para roleId 1
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onPressed: () {
                                        // Acción de edición del domicilio
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
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => PQRSForm()),
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