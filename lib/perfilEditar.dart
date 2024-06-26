import 'package:flutter/material.dart';
import 'index.dart';
import 'main.dart';
import 'perfil.dart'; 
import 'selectedItemPainter.dart';

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
      Navigator.pop(context);
    } else if (index == 1) {
      Navigator.pushNamed(context, '/perfil');
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 227, 255), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Perfil del Domiciliario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Información detallada del domiciliario',
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
                      'Para editar la información de usuario, debe acceder a su perfil desde la web.',
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
                          onPressed: () {
                            // Lógica para editar el perfil
                          },
                          child: const Text(
                            'Ir a la web',
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
        ),
      ),
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/img/imageVolver.png')),
                label: 'Regresar',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/img/imagePerfil.png')),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/img/imageDomicilio.png')),
                label: 'Domicilios',
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
