import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class PQRSForm extends StatefulWidget {

  final int domicilioId; // Añadir esta línea

  PQRSForm({required this.domicilioId});

  @override
  _PQRSFormState createState() => _PQRSFormState();
}

class _PQRSFormState extends State<PQRSForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTipo;
  final _motivoController = TextEditingController();
  bool _isMotivoValid = false;

  void _validateMotivo(String value) {
    setState(() {
      _isMotivoValid = value.length >= 10;
    });
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  void enviarPQRS() async {
    String tipoPQRS = _selectedTipo!;
    String motivo = _motivoController.text;
    String apiUrl = 'https://modisteria-back-production.up.railway.app/api/pqrs/createPQRS';

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-token');

    try{

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-token': token ?? '',
        },
        body: jsonEncode(<String, dynamic>{
          'tipo': tipoPQRS,
          'motivo': motivo,
          'usuarioId': user!.id,
          'domicilioId': widget.domicilioId
        }),
      );

      if(response.statusCode == 201){

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          showCloseIcon: false,
          title: "Se envió tu P.Q.R.S ",
          dialogBackgroundColor	: const Color.fromRGBO(255, 255, 255, 1),
          barrierColor: const Color.fromARGB(147, 26, 26, 26),
          desc: "Estaremos pendientes a tus nuevas Recomendaciones.",
          headerAnimationLoop: true,
          btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
          },
          descTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
          buttonsBorderRadius : const BorderRadius.all(Radius.circular(500)),
          titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)
        ).show();

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
                  "Error al enviar la P.Q.R.S",
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

    }catch(e){
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('P.Q.R.S para el Domicilio #${widget.domicilioId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feedback, size: 40, color: Colors.purple),
                  SizedBox(width: 10),
                  Text(
                    'P.Q.R.S',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Por favor, completa el formulario para enviar tu petición, queja, reclamo o sugerencia.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                decoration: InputDecoration(
                  labelText: 'Tipo de PQRS',
                  fillColor: Colors.grey.shade200,
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 3, style: BorderStyle.solid, color: Colors.purple),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 0, style: BorderStyle.none),
                  ),
                  filled: true,
                ),
                items: ['Sugerencia','Petición', 'Queja', 'Reclamo'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTipo = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El tipo de PQRS es necesario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _motivoController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Motivo',
                  hintText: 'Describe brevemente tu PQRS',
                  hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                  fillColor: Colors.grey.shade200,
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 3, style: BorderStyle.solid, color: Colors.purple),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 0, style: BorderStyle.none),
                  ),
                  filled: true,
                  suffixIcon: _isMotivoValid
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.error, color: Colors.red),
                ),
                onChanged: _validateMotivo,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El motivo es necesario';
                  } else if (value.length < 10) {
                    return 'El motivo debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          enviarPQRS();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Enviar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                        _motivoController.clear();
                        setState(() {
                          _selectedTipo = null;
                          _isMotivoValid = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Resetear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PQRSForm(domicilioId: 1),
  ));
}
