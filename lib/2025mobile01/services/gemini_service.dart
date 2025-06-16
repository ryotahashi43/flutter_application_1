// lib/2025mobile01/services/gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const apiKey = 'YOUR_API_KEY'; // ← 自分のAPIキーに置き換えてください

Future<String> getGeminiResponse(String userInput) async {
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
  );

  final headers = {
    'Content-Type': 'application/json',
  };

  final body = json.encode({
    "contents": [
      {
        "parts": [
          {"text": userInput}
        ]
      }
    ]
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'];
  } else {
    print('エラー: ${response.statusCode}');
    print('レスポンス: ${response.body}');
    return 'エラーが発生しました: ${response.statusCode}';
  }
}
