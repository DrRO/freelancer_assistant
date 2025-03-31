import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY']!;

  static Future<String> generateContent(String prompt) async {
    try {
      final model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Error: No response from Gemini.";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
}
