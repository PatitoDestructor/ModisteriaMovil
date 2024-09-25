import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'index.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import '../models/user.dart';
import 'recuperarContraseña.dart';
import 'package:jwt_decode/jwt_decode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('loggedIn') ?? false;
  runApp(
        MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(loggedIn: loggedIn),
    ),
    );
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Raleway',
        colorScheme: const ColorScheme.light(),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: loggedIn ? '/index' : '/login',
      routes: {
        '/login': (context) => const RegisterPage(),
        '/index': (context) => MyHomePage(),
      },
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contraController = TextEditingController();

void _login() async {
  if (_formKey.currentState!.validate()) {
    String email = _correoController.text.trim();
    String password = _contraController.text.trim();
    String apiUrl = 'https://modisteria-back-production.up.railway.app/api/usuarios/login';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Respuesta del servidor: $jsonResponse');

        // Decodificar el token JWT
        String token = jsonResponse['token'];
        Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

        // Acceder a los datos del usuario dentro del campo 'payload'
        Map<String, dynamic> userData = decodedToken['payload'];

        print('ID: ${userData['id']}');
        print('Email: ${userData['email']}');
        print('Nombre: ${userData['nombre']}');
        print('Telefono: ${userData['telefono']}');
        print('Password: ${userData['password']}');
        print('Direccion: ${userData['direccion']}');
        print('Role: ${userData['role']}');

        // Verificar si el campo 'id' es nulo
        if (userData['id'] != null) {
          // Crear un objeto User con los datos del token decodificado
          User user = User(
            id: userData['id'],
            nombre: userData['nombre'],
            email: userData['email'],
            telefono: userData['telefono'],
            password: userData['password'],  // Cambié de 'contraseña' a 'password'
            direccion: userData['direccion'] ?? '',  // Manejar el caso nulo
            roleId: userData['role']['id'],  // Acceder correctamente al campo id dentro de role
          );

          // Guardar los datos del usuario en el UserProvider
          Provider.of<UserProvider>(context, listen: false).saveUser(user);

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
                    "Bienvenido querido usuario",
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

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('loggedIn', true);

          // Navega al dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else {
          print('Error: El campo "id" es nulo');
        }
      } else {
        // Manejo de error en el inicio de sesión
        print('Error de inicio de sesión: ${response.statusCode}');
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
                  "Credenciales Incorrectas",
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
      // Manejo de error genérico
      print('Error al conectarse al servidor: $e');
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 40, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 50, bottom: 30, left: 60),
                child: const Text(
                  'Modisteria D.L',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                      color: Colors.black),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 120, bottom: 30),
                child: const Text(
                  'Ingresar',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.black),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _correoController,
                        decoration: InputDecoration(
                          hintText: 'Correo:',
                          hintStyle:
                              const TextStyle(fontWeight: FontWeight.w600),
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
                            return "El correo es necesario";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _contraController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Contraseña:',
                          hintStyle:
                              const TextStyle(fontWeight: FontWeight.w600),
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
                      padding: const EdgeInsets.only(top: 30, bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.black,
                            foregroundColor:
                                Colors.white, 
                          ),
                          child: const Text('Ingresar'),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PasswordRecoveryPage()),
                          );
                        },
                        child: const Text(
                          'Recuperar contraseña',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.purple, // Cambia el color si lo deseas
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 0),
                      child: const Text(
                        'O continua con',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Image(
                          image: NetworkImage(
                              'https://image.similarpng.com/very-thumbnail/2020/06/Logo-google-icon-PNG.png'),
                          height: 25,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text(
                        'Aceptando Terminos de servicio y Politicas de privacidad',
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}