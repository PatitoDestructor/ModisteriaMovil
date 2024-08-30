import 'package:flutter/material.dart';

class PQRSForm extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario P.Q.R.S'),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.thumb_up, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text('¡Formulario enviado con éxito!'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
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
    home: PQRSForm(),
  ));
}
