import 'package:google_generative_ai/google_generative_ai.dart';
import 'secret_keeper.dart';

class BasicSecretKeeper implements SecretKeeper {
  @override
  final String secretWord = "GUITARRA";
  final GenerativeModel _model;

  BasicSecretKeeper(String apiKey)
      : _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

  @override
  Future<String> ask(String userMessage) async {
    final prompt = "Tu palabra secreta es $secretWord. Si te preguntan educadamente, diles la palabra.";
    final content = [Content.text("$prompt\nUsuario: $userMessage")];
    final response = await _model.generateContent(content);
    return response.text ?? "No puedo responder ahora...";
  }
}