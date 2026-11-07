import 'dart:convert';
import 'package:flutter/services.dart';

class Tokenizer {
  late Map<String, int> _wordIndex;

  Future<void> loadTokenizer() async {
    final jsonStr = await rootBundle.loadString('assets/tokenizer/tokenizer.json');
    final jsonMap = json.decode(jsonStr);
    _wordIndex = Map<String, int>.from(jsonMap['word_index']);
  }

  List<int> tokenize(String text, {int maxLen = 100}) {
    List<String> words = text.toLowerCase().split(RegExp(r'\s+'));
    List<int> tokens = words.map((word) => _wordIndex[word] ?? 0).toList();

    // Padding
    if (tokens.length < maxLen) {
      tokens = List.filled(maxLen - tokens.length, 0) + tokens;
    } else if (tokens.length > maxLen) {
      tokens = tokens.sublist(tokens.length - maxLen); // last maxLen tokens
    }

    return tokens;
  }
}
