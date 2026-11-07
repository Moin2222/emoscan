import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ModelHandler {
  late Interpreter sentimentInterpreter;
  late Interpreter emotionInterpreter;
  late Interpreter emojiInterpreter;
  late Tokenizer tokenizer;

  Future<void> loadModels() async {
  try {
    sentimentInterpreter = await Interpreter.fromAsset('model/model_sentiment.tflite');
    emotionInterpreter = await Interpreter.fromAsset('model/model_emotions.tflite');
    emojiInterpreter = await Interpreter.fromAsset('model/emoji_model.tflite');

    tokenizer = await loadTokenizer(); // ✅ Assign the result here

    logger.i("All models and tokenizer loaded successfully.");
  } catch (e) {
    logger.e("Failed to load models: $e");
  }
}

Future<Tokenizer> loadTokenizer() async {
  final jsonStr = await rootBundle.loadString('assets/tokenizer/tokenizer.json');
  final jsonMap = json.decode(jsonStr);
  logger.i("Tokenizer loaded.");
  return Tokenizer.fromJson(jsonMap); // ✅ Return it
}


  List<List<double>> preprocess(String text) {
    final input = tokenizer.tokenize(text.toLowerCase());
    final vector = tokenizer.convertTokensToIds(input);
    final padded = padSequence(vector, 100);
    return [padded.map((e) => e.toDouble()).toList().cast<double>()];
  }

  List<int> padSequence(List<int> sequence, int maxLen) {
    if (sequence.length > maxLen) {
      return sequence.sublist(0, maxLen);
    } else {
      return sequence + List.filled(maxLen - sequence.length, 0);
    }
  }

  Future<List<double>> runModel(Interpreter interpreter, List<List<double>> input, int outputSize) async {
    var output = List.filled(1 * outputSize, 0.0).reshape([1, outputSize]);
    interpreter.run(input, output);
    return List<double>.from(output[0]); // ensures correct type
  }

  Future<Map<String, double>> predictAll(String text) async {
    try {
      List<List<double>> input = preprocess(text);
      var sentiment = await runModel(sentimentInterpreter, input, 3); // assuming 3 sentiment classes
      var emotion = await runModel(emotionInterpreter, input, 5);     // assuming 5 emotion classes
      var emoji = await runModel(emojiInterpreter, input, 5);         // assuming 5 emoji classes

      return {
        'sentiment': sentiment,
        'emotion': emotion,
        'emoji': emoji,
      };
    } catch (e) {
      logger.e("Prediction failed: $e");
      return {
        'sentiment': [],
        'emotion': [],
        'emoji': [],
      };
    }
  }

  void close() {
    sentimentInterpreter.close();
    emotionInterpreter.close();
    emojiInterpreter.close();
  }
}

class Tokenizer {
  late Map<String, int> wordIndex;

  Tokenizer({required this.wordIndex});

  factory Tokenizer.fromJson(Map<String, dynamic> json) {
    Map<String, int> wordIndex = {};
    json['word_index'].forEach((key, value) {
      wordIndex[key] = value;
    });
    return Tokenizer(wordIndex: wordIndex);
  }

  List<String> tokenize(String text) {
    return text.toLowerCase().split(RegExp(r'\s+'));
  }

  List<int> convertTokensToIds(List<String> tokens) {
    return tokens.map((token) => wordIndex[token] ?? 0).toList();
  }
}
