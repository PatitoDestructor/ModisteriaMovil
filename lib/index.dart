import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editarDomicilio.dart';
import 'perfil.dart';
import 'main.dart';
import 'mostrarDomiciliosPorEstado.dart';
import 'selectedItemPainter.dart';
import 'providers/user_provider.dart';
import 'package:provider/provider.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      ); // Navegación a la página de Domicilios
    }
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Perfil()),
      ); // Navegación a la página Perfil
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
            const Text(
              'Mis Domicilios',
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
            const Text(
              'Filtrar Domicilios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple, width: 2),
                color: Colors.white,
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedEstado,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEstado = newValue!;
                  });
                },
                items: <String>[
                  'Seleccione una opción',
                  'Pendiente',
                  'Entregado',
                  'Cancelado'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                dropdownColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: MostrarDomiciliosPorEstado(estado: _selectedEstado), // Widget que muestra domicilios filtrados
            ),
          ],
        ),
      ),
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
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
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.black,
            onTap: _onItemTapped,
            elevation: 10,
            selectedFontSize: 16,
            unselectedFontSize: 14,
          ),
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 2),
            painter: SelectedItemPainter(
              selectedIndex: _selectedIndex,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}
