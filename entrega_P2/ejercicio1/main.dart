import 'package:flutter/material.dart';
import 'package:flutter_application_1/target.dart';
import 'filtros.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filtros',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PantallaRegistro(),
    );
  }
}

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});
  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  late GestorFiltros _gestor;

  late Cliente _cliente;

  final List<String> _usuariosRegistrados = ["profe@gmail.com", "alumno@hotmail.com"];

  @override
  void initState() {
    super.initState();

    // Crear el target
    final target = AutenticacionTarget(_usuariosRegistrados);

    // Configuramos el gestor con sus filtros
    _gestor = GestorFiltros(target)
    .. agregarFiltro(FiltroCorreoTexto())
    .. agregarFiltro(FiltroCorreoDominio())
    .. agregarFiltro(FiltroPasswordLongitud())
    .. agregarFiltro(FiltroPasswordMayuscula())
    .. agregarFiltro(FiltroPasswordEspecial())
    // El filtro mira la misma lista que el Target actualiza
    .. agregarFiltro(FiltroEmailExistente(_usuariosRegistrados));

    // Inicializar el Cliente
    _cliente = Cliente(_gestor);
  }

  void _validar() {
    //La UI solo llama al cliente y espera el resultado para la notificación
    String resultado = _cliente.enviarPeticion(_emailController.text, _passController.text);

    // Lógica de notificación
    bool esExito = resultado == "¡Registro completado con éxito!";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado),
        backgroundColor: esExito ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(title: const Text("Práctica 2: Filtros")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _validar, child: const Text("Registrar"))
          ],
        ),
      ),
    );
  }
}
