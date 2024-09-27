import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'perfil.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class NewPasswordPage extends StatefulWidget {
  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmarController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _updatePassword() async {

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (_formKey.currentState!.validate()) {
      final newPassword = _passwordController.text.trim();
      final confirmarPassword = _passwordConfirmarController.text.trim();

      if (newPassword == confirmarPassword) {
        // Obtener el token almacenado en SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('x-token');

        String apiUrl = 'https://modisteria-back-production.up.railway.app/api/usuarios/resetCurrentPassword';

        try {
          var response = await http.post(
            Uri.parse(apiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-token': token ?? '', // Incluir el token en el encabezado
            },
            body: jsonEncode(<String, String>{
              'email': user!.email, // Reemplaza con el email correspondiente
              'newPassword': newPassword,
            }),
          );

          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);

                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.scale,
                  showCloseIcon: false,
                  title: "Correcto",
                  dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
                  barrierColor: const Color.fromARGB(147, 26, 26, 26),
                  desc: "La Contraseña se actualizó correctamente.",
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
          } else {
            var jsonResponse = jsonDecode(response.body);
            _showErrorSnackbar(jsonResponse['msg'] ?? "Error al actualizar la contraseña");
          }
        } catch (e) {
          _showErrorDialog('Error al conectar con el servidor.');
        }
      } else {
        _showErrorSnackbar("Las contraseñas deben coincidir");
      }
    }
  }

  void _showErrorSnackbar(String message) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          showCloseIcon: false,
          title: "Ups...",
          dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
          barrierColor: const Color.fromARGB(147, 26, 26, 26),
          desc: message,
          btnCancelOnPress: () {},
          autoHide: const Duration(seconds: 4),
          descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
          buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
          titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
        ).show();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Hace que el AppBar sea transparente
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Volver a la pantalla anterior
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/img/restablecer.png', // Agrega tu logo aquí
                      height: 100,
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            "Actualizar Contraseña",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Nueva Contraseña',
                              hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                              fillColor: Colors.grey.shade200,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3,
                                    style: BorderStyle.solid,
                                    color: Colors.purple),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0, style: BorderStyle.none),
                              ),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "La contraseña es necesaria";
                              } else if (value.length < 8) {
                                return "La contraseña debe tener al menos 8 caracteres";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _passwordConfirmarController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Confirmar Contraseña',
                              hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                              fillColor: Colors.grey.shade200,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3,
                                    style: BorderStyle.solid,
                                    color: Colors.purple),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0, style: BorderStyle.none),
                              ),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "La contraseña es necesaria";
                              } else if (value.length < 8) {
                                return "La contraseña debe tener al menos 8 caracteres";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Recuerda crear una Contraseña segura y que para ti sea facil de recordar.",
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _updatePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Actualizar Contraseña',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
