import 'package:flutter/material.dart';
import 'package:modisteria2/index.dart';
import 'perfilEditar.dart';
import 'selectedItemPainter.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'index.dart';

class Perfil extends StatefulWidget {
  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  int userRating = 5; 
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

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 227, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 227, 255),
      ),
      body: Center(
        child: user != null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Perfil del Domiciliario',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    'assets/img/imagePerfil.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //NOMBRE
                    Text(
                      'Nombre: ${user.nombre}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                  //APELLIDO
                    Text(
                      'Apellidos: ${user.apellido}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                  //EMAIL
                  Text(
                      'Email: ${user.gmail}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'Domiciliario',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Número de entregas: 76',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Venezolano',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Calificación por usuario',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(userRating, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/img/imageEstrella.png',
                            width: 30,
                            height: 30,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10), // Espacio entre la tarjeta y los botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const  BorderSide(color: Colors.black),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditarPerfil()),
                    );
                  },
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ],
        ) : const CircularProgressIndicator(),
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
