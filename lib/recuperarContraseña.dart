import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:modisteria2/main.dart';

String globalEmail = '';


class PasswordRecoveryPage extends StatefulWidget {
  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  void _sendRecoveryEmail() async {

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      globalEmail = email;
      String apiUrl = 'https://api-usuarios-zbi6.onrender.com/enviarCorreo';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return CodeVerificationModal(email: email);
          },
        );
      }
      else if(response.statusCode == 404) {
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
                      "El Correo no existe",
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
      else{
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
                      "Error al enviar el correo",
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

    } catch (e) {
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
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "El correo es necesario";
    }
    String pattern =
        r'^[^@]+@[^@]+\.[^@]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return "Introduce un correo válido";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo:',
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
                  validator: _validateEmail,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _sendRecoveryEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Enviar Código'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CodeVerificationModal extends StatefulWidget {
  final String email;

  CodeVerificationModal({required this.email});

  @override
  _CodeVerificationModalState createState() => _CodeVerificationModalState();
}

class _CodeVerificationModalState extends State<CodeVerificationModal> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      final code = _codeController.text.trim();

      String apiUrl = 'https://api-usuarios-zbi6.onrender.com/validarCodigo';

      try{
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': globalEmail,
            'code': code,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PasswordUpdatePage(email: widget.email)),
          );

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
                      "Código Verificado",
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
                backgroundColor: const Color.fromARGB(255, 12, 195, 106),
              ),
            );
        }
        else if(response.statusCode == 400){
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
                      "Codigo Incorrecto",
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

      }
      catch(e){
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: 'Código de Recuperación',
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
                    return "El código es necesario";
                  } else {
                    return null;
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 10),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Verificar Código'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class PasswordUpdatePage extends StatefulWidget {
  final String email;

  PasswordUpdatePage({required this.email});

  @override
  _PasswordUpdatePageState createState() => _PasswordUpdatePageState();
}

class _PasswordUpdatePageState extends State<PasswordUpdatePage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmarController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      final newPassword = _passwordController.text.trim();
      final confirmarPass = _passwordConfirmarController.text.trim();

      if(newPassword == confirmarPass){

      String apiUrl = 'https://api-usuarios-zbi6.onrender.com/actualizarPass';

      try{

        var response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': globalEmail,
          'contraseña': newPassword
        }),
      );

        if (response.statusCode == 200) {

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
                      "Contraseña actualizada Correctamente",
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
                backgroundColor: const Color.fromARGB(255, 12, 195, 106),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
        }
        else if(response.statusCode == 400) {
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
                      "Error al actualizar la Contraseña",
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

      }
      catch(e){
        print(e);
      }
    }
    else{
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
                      "Las contraseñas deben de ser iguales",
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
  }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Actualizar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextFormField(
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
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextFormField(
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
                    }else {
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Actualizar Contraseña'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
