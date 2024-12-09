import 'package:flutter/material.dart';
import 'package:modisteria2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl/intl.dart';
import 'AgregarCitaForm.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;
  List<dynamic> _citas = [];
  List<dynamic> _filteredCitas = [];
  int? _selectedEstadoId;
    List<Map<String, dynamic>> _insumos = [];
  String? _selectedInsumo;
  int? _cantidadInsumo;

  final Map<int, String> estados = {
    0: 'Todas',
    9: 'Por aprobar',
    10: 'Cotizada',
    11: 'Aceptada',
    12: 'Cancelada',
    13: 'Terminada',
  };

  @override
  void initState() {
    super.initState();
    _fetchCitas();
    _fetchInsumos();
  }

  Future<void> _fetchCitas() async {
    final url = Uri.parse("https://modisteria-back-production.up.railway.app/api/citas/getAllCitas");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-token': token ?? '',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _citas = json.decode(response.body);
          _filteredCitas = _citas; // Al inicio, mostrar todas las citas
          _isLoading = false;
        });
      } else {
        print("Error al obtener citas: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Excepción al obtener citas: $e");
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

  void _filterByEstado(int? estadoId) {
    setState(() {
      _selectedEstadoId = estadoId;
      _filteredCitas = estadoId == null || estadoId == 0
          ? _citas // Mostrar todas las citas si "Todas" está seleccionado
          : _citas.where((cita) => cita['estadoId'] == estadoId).toList();
    });
  }

  String _formatFecha(String fecha) {
    final dateTime = DateTime.parse(fecha);
    return DateFormat('MM/dd/yyyy').format(dateTime);
  }

  String _formatHora(String fecha) {
    final dateTime = DateTime.parse(fecha);
    return DateFormat('hh:mm a').format(dateTime);
  }

  String _formatPrecio(int amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'es_CO',
      symbol: 'COP',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      showCloseIcon: false,
      title: "Hasta Pronto",
      desc: "Cerraste sesión correctamente.",
      headerAnimationLoop: true,
      btnOkOnPress: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RegisterPage()),
          (Route<dynamic> route) => false,
        );
      },
    ).show();
  }

void _mostrarModalUsuario(BuildContext context, Map<String, dynamic> usuario) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage('assets/img/user.png'),
              ),
              const SizedBox(height: 20),
              Text(
                usuario['nombre'] ?? 'Nombre del Cliente',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Correo: ${usuario['email'] ?? 'No disponible'}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Teléfono: ${usuario['telefono'] ?? 'No disponible'}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Dirección: ${usuario['direccion'] ?? 'No disponible'}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _enviarCorreo(String? email, String fecha, String hora, String username) async {
    if (email == null || email.isEmpty) {
      print("Correo del usuario no encontrado");
      return;
    }
    const apiUrl = 'https://modisteria-back-production.up.railway.app/api/usuarios/sendEmail';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-token');
    String cuerpo = '''
    Querido usuario ${username},
    Su cita para el ${fecha} a las ${hora},
    fue cancelada.".
    ''';
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-token': token ?? '',
        },
        body: jsonEncode(<String, String>{
          'asunto': 'Cita cancelada.',
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

Future<void> _deleteCita(BuildContext context, Map<String, dynamic> cita) async {
  final int citaId = cita['id'];
  final String email = cita['usuario']['email'];
  final String nombreUsuario = cita['usuario']['nombre'];
  final String fechaCita = _formatFecha(cita['fecha']);
  final String horaCita = _formatHora(cita['fecha']);
  final url = Uri.parse('https://modisteria-back-production.up.railway.app/api/citas/cancelarCita/$citaId');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('x-token');


  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-token': token ?? '',
      },
    );

    if (response.statusCode == 201) {

      await _enviarCorreo(
        email,
        fechaCita,
        horaCita,
        nombreUsuario,
      );

      AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      showCloseIcon: false,
      title: "Perfecto",
      dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
      barrierColor: const Color.fromARGB(147, 26, 26, 26),
      desc: "Cita cancelada exitosamente.",
      headerAnimationLoop: true,
      btnOkOnPress: () {
        _fetchCitas();
      },
      descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
      buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
      titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
      ).show();

    }else if(response.statusCode == 400){
      AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      showCloseIcon: false,
      title: "Ups...",
      dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
      barrierColor: const Color.fromARGB(147, 26, 26, 26),
      desc: "La cita aún no ha sido aprobada.",
      headerAnimationLoop: true,
      btnOkOnPress: () {
      },
      descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
      buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
      titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
      ).show();
    } 
    
    else {
      AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      showCloseIcon: false,
      title: "Ups...",
      dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
      barrierColor: const Color.fromARGB(147, 26, 26, 26),
      desc: "Error al cancelar la Cita.",
      headerAnimationLoop: true,
      btnOkOnPress: () {
      },
      descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
      buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
      titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
      ).show();
    }
  } catch (e) {
    print("Error al eliminar la cita: $e");
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: "Error",
      desc: "Ocurrió un error. Inténtalo más tarde.",
      btnOkOnPress: () {},
    ).show();
  }
}

String _convertirHora(String tiempo) {
  final formatoEntrada = DateFormat("h:mm");
  final formatoSalida = DateFormat("HH:mm:ss");
  try {
    final hora = formatoEntrada.parse(tiempo);
    return formatoSalida.format(hora);
  } catch (e) {
    print('Error al convertir la hora: $e');
    return "00:00:00";
  }
}

Future<void> _aprobarCita(int id, int estadoId, String tiempo, String precio, int insumo, int cantidad) async {
  final url = Uri.parse('https://modisteria-back-production.up.railway.app/api/citas/updateSPT/$id');
  final urlInsumos = Uri.parse('https://modisteria-back-production.up.railway.app/api/citas/updateCitaInsumos/$id');
  String tiempoFormateado = _convertirHora(tiempo);
  int precioEntero = int.parse(precio);

  List<Map<String, dynamic>> datosInsumos = [
    {
      'insumo_id': insumo,
      'cantidad_utilizada': cantidad,
    }
  ];

  try {
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(<String, dynamic>{
        'estadoId': 10,
        'tiempo': tiempoFormateado,
        'precio': precioEntero,
      }),
    );

    if (response.statusCode == 201) {

      final responseInsumos = await http.put(
        urlInsumos,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(<String, dynamic>{
          'datosInsumos':datosInsumos
        }),
      );

      if (responseInsumos.statusCode == 200) {
        print("insumos descontados");
      }else{
        print("error al descontar insumos");
      }

      AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      showCloseIcon: false,
      title: "Perfecto",
      dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
      barrierColor: const Color.fromARGB(147, 26, 26, 26),
      desc: "Cita Aprobada.",
      headerAnimationLoop: true,
      btnOkOnPress: () {
        _fetchCitas();
      },
      descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
      buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
      titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
      ).show();
    } else {
        final responseData = jsonDecode(response.body);
        final msg = responseData['msg'];

        AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        showCloseIcon: false,
        title: "Ups...",
        dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
        barrierColor: const Color.fromARGB(147, 26, 26, 26),
        desc: "${msg}",
        headerAnimationLoop: true,
        btnOkOnPress: () {
        },
        descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
        buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
        titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
        ).show();
    }
  } catch (e) {
    print('Error en la solicitud: $e');
  }
}

Future<void> _editarCita(int id, int estadoId, String tiempo, String precio) async {
  final url = Uri.parse('https://modisteria-back-production.up.railway.app/api/citas/updateCita/$id');
  String tiempoFormateado = _convertirHora(tiempo);
  int precioEntero = int.parse(precio);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('x-token');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-token': token ?? '',
      },
      body: json.encode({
        'estadoId': estadoId,
        'tiempo': tiempoFormateado,
        'precio': precioEntero,
      }),
    );

    if (response.statusCode == 201) {
      AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      showCloseIcon: false,
      title: "Perfecto",
      dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
      barrierColor: const Color.fromARGB(147, 26, 26, 26),
      desc: "Cita editada exitosamente.",
      headerAnimationLoop: true,
      btnOkOnPress: () {
        _fetchCitas();
      },
      descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
      buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
      titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
      ).show();
    } else {
        AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        showCloseIcon: false,
        title: "Ups...",
        dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
        barrierColor: const Color.fromARGB(147, 26, 26, 26),
        desc: "Error al editar la Cita.",
        headerAnimationLoop: true,
        btnOkOnPress: () {
        },
        descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
        buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
        titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
        ).show();
        
        print(response.statusCode);
        print(response.body);
    }
  } catch (e) {
    print('Error en la solicitud: $e');
  }
}

void _mostrarModalAprobarCita(BuildContext context, Map<String, dynamic> cita) {
  final _tiempoController = TextEditingController();
  final _precioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  
  String? _selectedInsumo;
  String? _cantidadInsumo;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Aprobar Cita',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Tiempo
                TextFormField(
                  controller: _tiempoController,
                  decoration: InputDecoration(
                    labelText: 'Tiempo',
                    prefixIcon: const Icon(Icons.timer, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        );
                      },
                    );

                    if (pickedTime != null) {
                      final now = DateTime.now();
                      final selectedTime = DateTime(
                          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
                      final formattedTime = DateFormat('h:mm').format(selectedTime);
                      _tiempoController.text = formattedTime;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecciona una hora.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Precio
                TextFormField(
                  controller: _precioController,
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
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce un precio.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, introduce un número válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Dropdown de Insumo y Cantidad
                FormBuilderDropdown<String>(
                  name: 'insumo',
                  decoration: InputDecoration(
                    labelText: 'Insumo',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _insumos.map((insumo) {
                    return DropdownMenuItem(
                      value: insumo['id'].toString(),
                      child: Text(insumo['nombre']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedInsumo = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecciona un insumo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                  onChanged: (value) {
                    _cantidadInsumo = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce la cantidad.';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 1) {
                      return 'Debe ser al menos 1.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Botones de Cancelar y Enviar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final tiempo = _tiempoController.text;
                          final precio = _precioController.text;
                          final citaId = cita['id'];
                          final estado = cita['estadoId'];
                          final insumo = int.parse(_selectedInsumo!);
                          final cantidad = int.parse(_cantidadInsumo!);

                          _aprobarCita(citaId, estado, tiempo, precio, insumo, cantidad);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _mostrarModalEditarCita(BuildContext context, Map<String, dynamic> cita) {
  final _tiempoController = TextEditingController();
  final _precioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Editar Cita',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Tiempo
                TextFormField(
                  controller: _tiempoController,
                  decoration: InputDecoration(
                    labelText: 'Tiempo',
                    prefixIcon: const Icon(Icons.timer, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        );
                      },
                    );

                    if (pickedTime != null) {
                      // Convertir TimeOfDay a DateTime y formatear a 12 horas sin AM/PM
                      final now = DateTime.now();
                      final selectedTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
                      final formattedTime = DateFormat('h:mm').format(selectedTime); // 12 horas sin AM/PM
                      _tiempoController.text = formattedTime;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecciona una hora.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Precio
                TextFormField(
                  controller: _precioController,
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
                    FilteringTextInputFormatter.digitsOnly, // Permitir solo números
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce un precio.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, introduce un número válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Botones de Cancelar y Enviar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor:Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final tiempo = _tiempoController.text;
                          final precio = _precioController.text;
                          final citaId = cita['id'];
                          final estado = cita['estadoId'];
                          _editarCita(citaId, estado, tiempo, precio);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor:Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _terminarCita(int id) async {
  final url = Uri.parse('https://modisteria-back-production.up.railway.app/api/citainsumos/endCitaCreateVenta');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('x-token');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-token': token ?? '',
      },
      body: json.encode({
        'citaId': id,
      }),
    );

    if (response.statusCode == 201) {
      AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      showCloseIcon: false,
      title: "Perfecto",
      dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
      barrierColor: const Color.fromARGB(147, 26, 26, 26),
      desc: "Cita finalizada exitosamente.",
      headerAnimationLoop: true,
      btnOkOnPress: () {
        _fetchCitas();
      },
      descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
      buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
      titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
      ).show();
    } else {
        AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        showCloseIcon: false,
        title: "Ups...",
        dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
        barrierColor: const Color.fromARGB(147, 26, 26, 26),
        desc: "Error al finalizar la Cita.",
        headerAnimationLoop: true,
        btnOkOnPress: () {
        },
        descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
        buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
        titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
        ).show();
        
        print(response.statusCode);
        print(response.body);
    }
  } catch (e) {
    print('Error en la solicitud: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Citas",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                _citas.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: _logout,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(

              ),
              child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  DropdownButton<int>(
                    value: _selectedEstadoId,
                    hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Selecciona un estado",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                    items: estados.entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (estadoId) {
                      _filterByEstado(estadoId);
                    },
                      style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    iconEnabledColor: Colors.purple,
                    iconDisabledColor: Colors.grey,
                    underline: Container(),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _filteredCitas.isEmpty
                        ? Center(
                            child: Text(
                              "No hay citas disponibles.",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredCitas.length,
                            itemBuilder: (context, index) {
                              final cita = _filteredCitas[index];
                              final usuario = cita['usuario'];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 4,
                                child: Container(
                                  decoration:  BoxDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage('assets/img/marco.jpeg'),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(15), 
                                  ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () => _mostrarModalUsuario(context, usuario),
                                            child: Text(
                                              usuario['nombre'],
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                            ),
                                          ),
                                          Text(
                                            "Fecha: ${_formatFecha(cita['fecha'])}",
                                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Objetivo: ${cita['objetivo']}",
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time, color: Colors.purple),
                                              const SizedBox(width: 5),
                                              Text(
                                                _formatHora(cita['fecha']),
                                                style: const TextStyle(fontSize: 16, color: Colors.purple, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Sub-card para precio y tiempo
                                          Card(
                                            color: Colors.grey[200],
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.attach_money, color: Colors.green),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        cita['precio'] != null ? _formatPrecio(cita['precio']) : "Sin definir",
                                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.timer, color: Colors.blue),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        cita['tiempo'] != null ? "${cita['tiempo']}" : "N/A",
                                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          // Botones Editar y Eliminar
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                            if(cita['estadoId'] == 9)
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  _mostrarModalAprobarCita(context, cita);
                                                },
                                                label: const Icon(Icons.check, color: Colors.white),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                ),
                                              ),

                                          if(cita['estadoId'] == 10)
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  _mostrarModalEditarCita(context, cita);
                                                },
                                                label: const Icon(Icons.edit, color: Colors.white),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                ),
                                              ),

                                              // if(cita['estadoId'] == 11)
                                              // ElevatedButton.icon(
                                              //   onPressed: () {
                                              //       AwesomeDialog(
                                              //       context: context,
                                              //       dialogType: DialogType.warning,
                                              //       animType: AnimType.scale,
                                              //       showCloseIcon: true,
                                              //       title: "Cuidado",
                                              //       dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
                                              //       barrierColor: const Color.fromARGB(147, 26, 26, 26),
                                              //       desc: "¿Estás seguro de terminar la cita de ${usuario['nombre']}?",
                                              //       headerAnimationLoop: true,
                                              //       btnOkOnPress: () {
                                              //         _terminarCita(cita['id']);
                                              //       },
                                              //       btnCancelText: "Cancelar",       // Texto del botón de Cancelar
                                              //       btnCancelOnPress: () {
                                              //       },
                                              //       descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
                                              //       buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
                                              //       titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
                                              //     ).show();
                                              //   },
                                              //   label: const Text('Terminar cita', style: TextStyle(color: Colors.white),),
                                              //   style: ElevatedButton.styleFrom(
                                              //     backgroundColor: Colors.purple,
                                              //     shape: RoundedRectangleBorder(
                                              //       borderRadius: BorderRadius.circular(20),
                                              //     ),
                                              //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              //   ),
                                              // ),

                                              if(cita['estadoId'] == 10)
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  AwesomeDialog(
                                                    context: context,
                                                    dialogType: DialogType.warning,
                                                    animType: AnimType.scale,
                                                    showCloseIcon: true,
                                                    title: "Cuidado",
                                                    dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
                                                    barrierColor: const Color.fromARGB(147, 26, 26, 26),
                                                    desc: "¿Estás seguro de cancelar la cita de ${usuario['nombre']}?",
                                                    headerAnimationLoop: true,
                                                    btnOkOnPress: () {
                                                      _deleteCita(context, cita);
                                                    },
                                                    btnCancelText: "Cancelar",       // Texto del botón de Cancelar
                                                    btnCancelOnPress: () {
                                                    },
                                                    descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
                                                    buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
                                                    titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
                                                  ).show();
                                                },
                                                label: const Icon(Icons.delete, color: Colors.white),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                ),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: _getEstadoColor(cita['estadoId']),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          estados[cita['estadoId']] ?? "Sin Estado",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AgregarCitaPage()),
              );
              _fetchCitas();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.purple,
          ),
    );
  }

  Color _getEstadoColor(int estadoId) {
    switch (estadoId) {
      case 9:
        return Colors.blue;
      case 10:
        return Colors.orange;
      case 11:
        return Colors.green;
      case 12:
        return Colors.red;
      case 13:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
