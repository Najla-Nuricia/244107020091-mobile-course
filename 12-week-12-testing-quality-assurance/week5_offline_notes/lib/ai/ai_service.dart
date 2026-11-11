import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiService {
  final _storage = const FlutterSecureStorage();

  static const systemPrompt =
      'Kamu adalah asisten belajar yang ringkas, akurat, dan aman. '
      'Jawab dalam bahasa Indonesia, jelaskan asumsi jika diperlukan, '
      'dan jangan mengarang fakta atau meminta data pribadi.';

  static const _apiUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/'
    'gemini-3.8-flash:generateContent';

  Future<String> ask(
    String question, {
    String systemInstruction = systemPrompt,
  }) async {
    if (question.trim().isEmpty) {
      throw ArgumentError('Pertanyaan tidak boleh kosong.');
    }

    final apiKey = await readApiKey();

    if (apiKey == null) {
      throw const ApiKeyMissingException();
    }

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': systemInstruction},
          ],
        },
        'contents': [
          {
            'parts': [
              {'text': question},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (text is String && text.trim().isNotEmpty) {
        return text;
      }

      throw Exception('Respons AI tidak berisi teks.');
    } else {
      String message = response.body;

      try {
        final data = jsonDecode(response.body);
        message = data['error']?['message'] ?? response.body;
      } catch (_) {}

      throw Exception(
        'Gemini API error (${response.statusCode}): $message',
      );
    }
  }

  Future<void> saveApiKey(String key) async {
    final normalizedKey = key.trim();

    if (normalizedKey.isEmpty) {
      throw ArgumentError('API key tidak boleh kosong.');
    }

    await _storage.write(
      key: 'ai_api_key',
      value: normalizedKey,
    );

    if (await readApiKey() != normalizedKey) {
      throw Exception('API key gagal disimpan ke secure storage.');
    }
  }

  Future<String?> readApiKey() async {
    final key = await _storage.read(key: 'ai_api_key');
    final normalizedKey = key?.trim();

    return normalizedKey == null || normalizedKey.isEmpty
        ? null
        : normalizedKey;
  }
}

class ApiKeyMissingException implements Exception {
  const ApiKeyMissingException();

  @override
  String toString() =>
      'API key belum disimpan. Tekan ikon kunci untuk mengaturnya.';
}