import 'package:flutter/material.dart';
import 'editarDomicilio.dart';
import 'perfil.dart';
import 'main.dart';
import 'mostrarDomiciliosPorEstado.dart';
import 'selectedItemPainter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filtrado por estados',
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
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      ); // Navegación a la página de Login
    }
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Perfil()),
      ); // Navegación a la página Perfil
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
              child: Image.asset('assets/img/imageDomicilio.png', fit: BoxFit.cover),
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    'Filtrar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 270,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 236, 197, 255),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: const Color.fromARGB(255, 236, 197, 255),
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
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(value),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
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
            onTap: _onItemTapped, // Manejador de tap en la barra de navegación
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
