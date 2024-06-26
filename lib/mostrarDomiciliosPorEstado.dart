import 'package:flutter/material.dart';
import 'domicilio.dart';
import 'editarDomicilio.dart';

class MostrarDomiciliosPorEstado extends StatelessWidget {
  final String estado;

  MostrarDomiciliosPorEstado({required this.estado});

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'Entregado':
        return Colors.green;
      case 'Cancelado':
        return Colors.grey;
      case 'Pendiente':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Domicilio>>(
      future: obtenerDomiciliosPorEstado(estado),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay domicilios disponibles'));
        } else {
          List<Domicilio> domiciliosFiltrados = snapshot.data!;
          return ListView.builder(
            itemCount: domiciliosFiltrados.length,
            itemBuilder: (context, index) {
              Domicilio domicilio = domiciliosFiltrados[index];
              Color textColor = _getColorForEstado(domicilio.estado);
              return Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${index + 1}. ${domicilio.direccion}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Descripción: ${domicilio.descripcion}'),
                              Row(
                                children: <Widget>[
                                  const Text('Valor Prenda: '),
                                  Text(
                                    '${domicilio.valorPrenda.toString()}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  const Text('Valor Domicilio: '),
                                  Text(
                                    '${domicilio.valorDomicilio.toString()}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text('Valor a Pagar: ${domicilio.valorPagar.toString()}'),
                              Row(
                                children: <Widget>[
                                  const Text(
                                    'Estado: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${domicilio.estado}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditarDomicilio(domicilio: domicilio),
                              ),
                            );
                          },
                          child: Container(
                            width: 25,
                            height: 25,
                            child: Image.asset(
                              'assets/img/imageEditar.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
