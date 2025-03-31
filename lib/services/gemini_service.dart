import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static late GenerativeModel _model;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        throw Exception(
          'API key not configured. Add GEMINI_API_KEY to .env file.',
        );
      }

      // ✅ Use the correct model name
      _model = GenerativeModel(
        model: 'gemini-1.5-pro', // Use 'gemini-1.5-pro' instead of 'gemini-pro'
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: 2000,
          temperature: 0.4,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        ],
      );

      _isInitialized = true;
      debugPrint('✅ GeminiService initialized successfully!');
    } catch (e) {
      debugPrint('❌ Gemini Initialization Error: $e');
      throw Exception('Gemini initialization failed: ${e.toString()}');
    }
  }

  static Future<String> generateContent(String prompt) async {
    if (!_isInitialized) await initialize();

    try {
      if (prompt.isEmpty) throw Exception('Prompt cannot be empty.');
      if (prompt.length < 10)
        throw Exception('Prompt too short (min 10 characters).');

      // ✅ Generate content
      final response = await _model.generateContent([Content.text(prompt)]);
      debugPrint('✅ Gemini API Response: ${response.text}');

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API.');
      }

      return response.text!;
    } catch (e) {
      debugPrint('❌ Gemini API Error: $e');
      throw Exception('Failed to generate content: ${_parseError(e)}');
    }
  }

  static String _parseError(dynamic error) {
    final message = error.toString();

    if (message.contains('API_KEY_INVALID'))
      return 'Invalid API key - please check your .env file.';
    if (message.contains('quota'))
      return 'API quota exceeded - try again later.';
    if (message.contains('safety'))
      return 'Content blocked by safety filters - try a different prompt.';
    if (message.contains('network'))
      return 'Network error - check your internet connection.';

    return 'Content generation failed. Please try again.';
  }
}
