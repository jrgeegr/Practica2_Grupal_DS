import 'package:flutter_application_1/credenciales.dart';
import 'package:flutter_application_1/filtros.dart';

class AutenticacionTarget {
  // Referencia a la lista que está en el filtro
  final List<String> baseDeDatos;

  AutenticacionTarget(this.baseDeDatos);

  String ejecutar(Credenciales credenciales){
    //Si llegó aquí es porque pasó todos los filtros
    baseDeDatos.add(credenciales.email.trim().toLowerCase());
    return "¡Registro completado con éxito!";
  }
}

class Cliente {
  final GestorFiltros _gestor;

  Cliente(this._gestor);

  String enviarPeticion(String email, String password) {
    return _gestor.enviarPeticion(email, password);
  }
}