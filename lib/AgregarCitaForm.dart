import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'index.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/services.dart';



class AgregarCitaPage extends StatefulWidget {
  @override
  _AgregarCitaPageState createState() => _AgregarCitaPageState();
}

class _AgregarCitaPageState extends State<AgregarCitaPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<Map<String, dynamic>> _usuarios = [];
  String? _selectedUsuario;
  List<Map<String, dynamic>> _insumos = [];
  String? _selectedInsumo;
  int? _cantidadInsumo;

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
    _fetchInsumos();
  }

Future<void> _fetchUsuarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-token');

    final response = await http.get(
      Uri.parse('https://modisteria-back-production.up.railway.app/api/usuarios/getAllUsers'),
      headers: {
        'Content-Type': 'application/json',
        'x-token': token ?? '',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _usuarios = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('Error al obtener los usuarios');
    }
  }

  Future<void> _fetchInsumos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-token');

    final response = await http.get(
      Uri.parse('https://modisteria-back-production.up.railway.app/api/insumos/getAllInsumos'),
      headers: {
        'Content-Type': 'application/json',
        'x-token': token ?? '',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _insumos = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('Error al obtener los insumos');
    }
  }

  Future<void> _enviarCorreo(String? email, String fecha, String hora, String objetivo, String username) async {
    if (email == null || email.isEmpty) {
      print("Correo del usuario no encontrado");
      return;
    }
    const apiUrl = 'https://modisteria-back-production.up.railway.app/api/usuarios/sendEmail';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-token');
    String cuerpo = '''
    Querido usuario ${username},
    Su cita fue agendada para el ${fecha} a las ${hora},
    con el objetivo de "${objetivo}".
    ''';
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-token': token ?? '',
        },
        body: jsonEncode(<String, String>{
          'asunto': 'Cita agendada con éxito.',
          'cuerpo': cuerpo,
          'email': email
        }),
      );

      if (response.statusCode == 200) {
        print('Correo enviado exitosamente');
      } else {
        print('Error al enviar correo: ${response.body}');
      }

      } catch (e) {
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

  Future<void> _mostrarDialogoExito(BuildContext context, String fecha, String hora, Map<String, dynamic> formData) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      showCloseIcon: false,
      title: "Perfecto",
      dialogBackgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      barrierColor: const Color.fromARGB(147, 26, 26, 26),
      desc: "Cita agendada exitosamente.",
      headerAnimationLoop: true,
      btnOkOnPress: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      },
      descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(500)),
      titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24),
    ).show();

    final usuarioSeleccionado = _usuarios.firstWhere((usuario) => usuario['id'] == formData['usuario']);
    final String emailUsuario = usuarioSeleccionado['email'];
    final String username = usuarioSeleccionado['nombre'];

    await _enviarCorreo(emailUsuario, fecha, hora, formData['objetivo'], username);
  }

  void _mostrarDialogoError(BuildContext context, String mensaje) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      showCloseIcon: true,
      title: "Ups...",
      dialogBackgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      barrierColor: const Color.fromARGB(147, 26, 26, 26),
      desc: mensaje,
      headerAnimationLoop: true,
      descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(500)),
      titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24),
    ).show();
  }

void _submitForm() async {
  if (_formKey.currentState!.saveAndValidate()) {
    final formData = _formKey.currentState!.value;

    try {
      final DateTime fechaSeleccionada = formData['fechaHora'];
      final String fechaIso = fechaSeleccionada.toIso8601String(); // Convertir a ISO 8601
      final String fechaFormateada = DateFormat('dd/MM/yyyy').format(fechaSeleccionada);
      final String horaFormateada = DateFormat('hh:mm a').format(fechaSeleccionada);
      final String tiempoFormateado = DateFormat('hh:mm').format(formData['hora']);

      final int precioEntero = int.tryParse(formData['precio']) ?? 0;

      const String apiUrl = "https://modisteria-back-production.up.railway.app/api/citas/crearCitaAdmin";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-token');

      List<Map<String, dynamic>> datosInsumos = [
        {
          'insumo_id': formData['insumo'],
          'cantidad_utilizada': formData['cantidadInsumo'],
        }
      ];

      // Enviar solicitud
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-token': token ?? '',
        },
        body: jsonEncode(<String, dynamic>{
          'fecha': fechaIso.toString(),
          'objetivo': formData['objetivo'],
          'usuarioId': formData['usuario'],
          'precio': precioEntero,
          'tiempo': tiempoFormateado.toString(),
          'estadoId': 10
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        var jsonResponse = jsonDecode(response.body);
        int citaId = jsonResponse['cita']['id'];
        final urlInsumos = Uri.parse('https://modisteria-back-production.up.railway.app/api/citainsumos/createAndDiscount');

        final responseInsumos = await http.post(
        urlInsumos,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(<String, dynamic>{
          'citaId': citaId,
          'datosInsumos':datosInsumos
        }),
      );

      if (responseInsumos.statusCode == 201) {
        print("insumos descontados");
      }else{
        print("error al descontar insumos");
      }

        print(jsonResponse);
        await _mostrarDialogoExito(context, fechaFormateada, horaFormateada, formData);


      } else {
        final responseData = jsonDecode(response.body);
        final msg = responseData['msg'] ?? "Error desconocido.";
        _mostrarDialogoError(context, msg);
      }
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      _mostrarDialogoError(context, "Error inesperado al enviar la cita.");
    }
  } else {
    print("Formulario inválido");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Cita', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              FormBuilderDateTimePicker(
                name: 'fechaHora',
                decoration: InputDecoration(
                  labelText: 'Fecha y Hora',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.black),
                ),
                initialEntryMode: DatePickerEntryMode.calendar,
                inputType: InputType.both,
                format: DateFormat('yyyy-MM-dd HH:mm'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'objetivo',
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Objetivo',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  alignLabelWithHint: true,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(10, errorText: 'Mínimo 10 caracteres'),
                ]),
              ),
              const SizedBox(height: 16),

              // Dropdown para los usuarios
              FormBuilderDropdown(
                name: 'usuario',
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.black),
                ),
                items: _usuarios.map((usuario) {
                  return DropdownMenuItem(
                    value: usuario['id'],
                    child: Text(usuario['nombre']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              FormBuilderDateTimePicker(
                name: 'hora',
                decoration: InputDecoration(
                  labelText: 'Hora',
                  prefixIcon: const Icon(Icons.timer, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                initialEntryMode: DatePickerEntryMode.input,
                inputType: InputType.time,
                format: DateFormat('hh:mm'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Por favor, selecciona una hora.'),
                ]),
              ),

              const SizedBox(height: 16),

              // Campo Precio
              FormBuilderTextField(
                name: 'precio',
                decoration: InputDecoration(
                  labelText: 'Precio',
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Permite solo números
                ],
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Por favor, introduce un precio.'),
                  FormBuilderValidators.min(1, errorText: 'El precio debe ser mayor que 0.'),
                ]),
              ),

              const SizedBox(height: 18),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration:  BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/img/marco.jpeg'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(15), 
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      FormBuilderDropdown(
                        name: 'insumo',
                        decoration: InputDecoration(
                          labelText: 'Insumo',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _insumos.map((insumo) {
                          return DropdownMenuItem(
                            value: insumo['id'],
                            child: Text(insumo['nombre']),
                          );
                        }).toList(),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'cantidadInsumo',
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.min(1, errorText: 'Debe ser al menos 1'),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),

              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Agendar Cita',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
