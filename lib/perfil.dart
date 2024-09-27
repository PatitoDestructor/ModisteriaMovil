import 'package:flutter/material.dart';
import 'package:modisteria2/index.dart';
import 'perfilEditar.dart';
import 'selectedItemPainter.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'package:bcrypt/bcrypt.dart';
import 'editarContraseña.dart';


class Perfil extends StatefulWidget {
  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  int userRating = 5;
  int _selectedIndex = 1;
  final TextEditingController _passwordController = TextEditingController();

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

void _showPasswordModal(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final user = userProvider.user;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: user != null
            ? Container(
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Validar Contraseña",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Contraseña:',
                                    hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                                    fillColor: Colors.grey.shade200,
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3,
                                          style: BorderStyle.solid,
                                          color: Colors.purple),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 0, style: BorderStyle.none),
                                    ),
                                    filled: true,
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "La contraseña es necesaria";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30, bottom: 10),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (BCrypt.checkpw(_passwordController.text, user.password)) {
                                        print("Contraseña correcta");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => NewPasswordPage()),
                                        );

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                const Icon(Icons.check_circle, color: Colors.white),
                                                const SizedBox(width: 5),
                                                Text(
                                                  "Contraseña Correcta.",
                                                  style: const TextStyle(color: Colors.white),
                                                ),
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
                                        _passwordController.clear();

                                      } else {
                                        print("Contraseña incorrecta");

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
                                                        "Contraseña Incorrecta.",
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
                                        _passwordController.clear();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Validar'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      );
    },
  );
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
                    Text(
                      user.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                              leading: const Icon(Icons.key, color: Colors.purple),
                              title: Text(
                                'ID: ${user.id}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone, color: Colors.purple),
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
                            ListTile(
                              leading: const Icon(Icons.lock, color: Colors.purple),
                              title: const Text(
                                'Contraseña: ********',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  _showPasswordModal(context);
                                },
                                child: const CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: Icon(Icons.edit, color: Colors.white),
                                ),
                              ),
                            ),
                            Divider(color: Colors.purple.shade100, thickness: 1),
                            ListTile(
                              leading: const Icon(Icons.recent_actors_outlined, color: Colors.purple),
                              title: Text(
                                user.roleId == 1
                                    ? 'USUARIO'
                                    : user.roleId == 2
                                        ? 'ADMINISTRADOR'
                                        : user.roleId == 3
                                            ? 'CLIENTE'
                                            : 'DOMICILIARIO',
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
