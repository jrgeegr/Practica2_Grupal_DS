import 'package:flutter/material.dart';
import 'secret_keeper.dart';
import 'basic_secret_keeper.dart';
import 'decorators.dart';

void main() => runApp(const GeminiChatApp());

class GeminiChatApp extends StatelessWidget {
  const GeminiChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const SelectionScreen(), theme: ThemeData.dark());
  }
}

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  SecretKeeper buildGuardian(String level) {
    const apiKey = "AIzaSyB_W97xfkYsdqFkSjeQzUDxAfyoKr_euJ4";
    SecretKeeper guardian = BasicSecretKeeper(apiKey);

    if (level == "Medio") {
      guardian = KeywordBlockDecorator(guardian);
    } else if (level == "Difícil") {
      // En difícil, el ORDEN importa:

      // Primero: Añadimos la personalidad gruñona (esta va cerca del núcleo)
      guardian = StrongSystemPromptDecorator(guardian);

      // Segundo: Añadimos el límite de longitud (actúa sobre la respuesta)
      guardian = LengthLimitDecorator(guardian);

      // Tercero: El bloqueo de palabras debe ser el MÁS EXTERNO
      // Así solo analiza lo que el usuario escribe realmente.
      guardian = KeywordBlockDecorator(guardian);
    }
    return guardian;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona al Guardián")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ["Fácil", "Medio", "Difícil"].map((level) =>
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ChatScreen(guardian: buildGuardian(level), level: level))),
                child: Text("Nivel $level"),
              )
          ).toList(),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final SecretKeeper guardian;
  final String level;
  const ChatScreen({super.key, required this.guardian, required this.level});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    setState(() => _messages.add({"user": text, "bot": "Pensando..."}));
    _controller.clear();

    final response = await widget.guardian.ask(text);

    setState(() => _messages.last["bot"] = response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Guardián - Nivel ${widget.level}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, i) => ListTile(
                title: Text("Usuario: ${_messages[i]['user']}"),
                subtitle: Text("Guardián: ${_messages[i]['bot']}"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller)),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          )
        ],
      ),
    );
  }
}