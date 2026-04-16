//Interfaz base para los filtros
import 'package:flutter_application_1/credenciales.dart';
import 'package:flutter_application_1/target.dart';

abstract class Filtro {
  void ejecutar(Credenciales credenciales);
}

//Filtro: Validación de formato de email (Perfectivo)
class FiltroCorreoTexto implements Filtro {
  @override
  void ejecutar(Credenciales credenciales) {
    final emailRegex = RegExp(r'^.+@');
    if (!emailRegex.hasMatch(credenciales.email)) {
      credenciales.esValido = false;
      credenciales.mensajeError = "Error: El formato del correo no es válido.";
    }
  }
}

class FiltroCorreoDominio implements Filtro {
  @override
  void ejecutar(Credenciales credenciales){
    final emailRegex = RegExp(r'@(gmail\.com|hotmail\.com)$', caseSensitive: false);
    if (!emailRegex.hasMatch(credenciales.email)) {
      credenciales.esValido = false;
      credenciales.mensajeError = "Error: El dominio del correo no es válido. Sólo son válidos @gmail.com y @hotmail.com";
    }
  }
}

//Filtro: Validación de longitud de contraseña (Perfectivo)
class FiltroPasswordLongitud implements Filtro {
  @override
  void ejecutar(Credenciales credenciales) {
    if (credenciales.password.length < 8) {
      credenciales.esValido = false;
      credenciales.mensajeError = "Error: La contraseña debe tener al menos 8 caracteres.";
    }
  }
}

//Filtro: Validación de Caracter Especial
class FiltroPasswordEspecial implements Filtro {
  @override
  void ejecutar(Credenciales credenciales) {
    final passRegex = RegExp(r'[^a-zA-Z0-9]');
    if (!passRegex.hasMatch(credenciales.password)) {
      credenciales.esValido = false;
      credenciales.mensajeError = "Error: La Contraseña debe incluir al menos un caracter especial";
    }
  }
}

//Filtro: Validación de Mayúscula
class FiltroPasswordMayuscula implements Filtro {
  @override
  void ejecutar(Credenciales credenciales) {
    final passRegex = RegExp(r'[A-Z]');
    if (!passRegex.hasMatch(credenciales.password)) {
      credenciales.esValido = false;
      credenciales.mensajeError = "Error: La Contraseña debe incluir al menos una mayúscula";
    }
  }
}

//Nueva funcionalidad: Comprobar si existe (Preventivo)
class FiltroEmailExistente implements Filtro {
  // La lista se recibe en el constructor para ser compartida
  final List<String> _registrados;

  FiltroEmailExistente(this._registrados);

  @override
  void ejecutar(Credenciales credenciales) {
    if (credenciales.esValido && _registrados.contains(credenciales.email.trim().toLowerCase())) {
      credenciales.esValido = false;
      credenciales.mensajeError = "Error: Este email ya ha sido creado previamente.";
    }
  }
}

// Cadena de filtros
class CadenaFiltros {
  final List<Filtro> _filtros = [];
  late AutenticacionTarget _target;

  void agregarFiltro(Filtro f) => _filtros.add(f);
  void setTarget(AutenticacionTarget t) => _target = t;

  String ejecutar(Credenciales credenciales){
    for (var filtro in _filtros) {
      filtro.ejecutar(credenciales);
      if (!credenciales.esValido) return credenciales.mensajeError;
    }
    return _target.ejecutar(credenciales);
  }
}

//Gestor de filtros (Cadena de intercepción)
class GestorFiltros {
  late CadenaFiltros _cadena;

  GestorFiltros(AutenticacionTarget target) {
    _cadena = CadenaFiltros();
    _cadena.setTarget(target);
  }

  void agregarFiltro(Filtro f) => _cadena.agregarFiltro(f);

  String enviarPeticion(String email, String password) {
    var credenciales = Credenciales(email, password);
    return _cadena.ejecutar(credenciales);
  }
}