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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: user != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/img/user.png'),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person, color: Colors.purple),
                                title: Text(
                                  'Nombre: ${user.nombre}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.phone , color: Colors.purple),
                                title: Text(
                                  'Telefono: ${user.telefono}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.email, color: Colors.purple),
                                title: Text(
                                  'Email: ${user.email}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(color: Colors.purple.shade100, thickness: 1),
                              ListTile(
                                leading: const Icon(Icons.motorcycle, color: Colors.purple),
                                title: Text(
                                  user.roleId == 1 ? 'Administrador' : user.roleId == 2 ? 'Cliente' : 'Domiciliario',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
              
                          const SizedBox(width: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditarPerfil()),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Text(
                                'Editar',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        onTap: _onItemTapped,
        elevation: 10,
        selectedFontSize: 16,
        unselectedFontSize: 14,
      ),
    );
  }
}
