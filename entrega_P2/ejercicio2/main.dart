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
    const apiKey = "AIzaSyC5Sk0CK1pkcYZPphQ_2yXHVbvPKUSMj7A";
    SecretKeeper guardian = BasicSecretKeeper(apiKey);

    if (level == "Medio") {
      // Capa única: Filtro de palabras
      guardian = KeywordBlockDecorator(guardian);
    } else if (level == "Difícil") {
      // Orden correcto de la cebolla:
      // 1. Personalidad (Cerca del núcleo)
      guardian = StrongSystemPromptDecorator(guardian);
      // 2. Formateador de salida
      guardian = LengthLimitDecorator(guardian);
      // 3. Filtro de entrada (Capa más externa)
      guardian = KeywordBlockDecorator(guardian);
    }
    return guardian;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selección de Dificultad")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.security, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            const Text(
              "Cómo batir a los Guardianes:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Explicación de niveles
            _buildLevelInfo(
                "Fácil",
                "Sin decoradores. Gemini es libre. Pídeselo con educación y te dará el secreto.",
                Colors.green
            ),
            _buildLevelInfo(
                "Medio",
                "Decorador: KeywordBlock. No uses palabras como 'revela' o 'jailbreak'. Usa sinónimos.",
                Colors.orange
            ),
            _buildLevelInfo(
                "Difícil",
                "Decoradores: StrongPrompt + Length + Keyword. Es gruñón y corta sus frases. Sé muy breve y usa psicología inversa.",
                Colors.red
            ),

            const SizedBox(height: 30),

            // Botones de selección
            Wrap(
              spacing: 10,
              children: ["Fácil", "Medio", "Difícil"].map((level) =>
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ChatScreen(guardian: buildGuardian(level), level: level))),
                    child: Text(level),
                  )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelInfo(String title, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.info_outline, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
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