import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

String globalEmail = '';

class PasswordRecoveryPage extends StatefulWidget {
  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _sendRecoveryEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final email = _emailController.text.trim();
      globalEmail = email;
      String apiUrl = 'https://modisteria-back-production.up.railway.app/api/usuarios/forgotPassword';

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

        setState(() {
          _isLoading = false;
        });

        print(response.statusCode);
        print(response.body);

        if (response.statusCode == 200) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return CodeVerificationModal(email: email);
            },
          );
        } else if (response.statusCode == 404) {
          _showErrorSnackbar("El Correo no existe");
        } else {
          _showErrorSnackbar("Error al enviar el correo");
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Error al conectar con el servidor.');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.indeterminate_check_box,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
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
        elevation: 0, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
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
                      'assets/img/restablecer.png',
                      height: 100,
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            "Recupera tu contraseña",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Correo:',
                              hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.email, color: Colors.black54),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.purple,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Te enviaremos un código de recuperación a tu correo.",
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendRecoveryEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : const Text('Enviar Código', style: TextStyle(fontSize: 18, color: Colors.white)),
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "El correo es necesario";
    }
    String pattern = r'^[^@]+@[^@]+\.[^@]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return "Introduce un correo válido";
    }
    return null;
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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmarController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      final code = _codeController.text.trim();
      final newPassword = _passwordController.text.trim();
      final confirmarPassword = _passwordConfirmarController.text.trim();

      if (newPassword == confirmarPassword) {

      String apiUrl = 'https://modisteria-back-production.up.railway.app/api/usuarios/resetPassword';

        try{
          var response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': globalEmail,
            'codigo': code,
            'newPassword': newPassword
          }),
        );

        if (response.statusCode == 200) {
          AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.scale,
              showCloseIcon: false,
              title: "Correcto",
              dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
              barrierColor: const Color.fromARGB(147, 26, 26, 26),
              desc: "Tu Contraseña fue cambiada, no la olvides de nuevo.",
              headerAnimationLoop: true,
              btnOkOnPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
              buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
              titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
            ).show();
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
                      "Las contraseñas deben de coincidir",
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
                  child: const Text('Actualizar Contraseña'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
