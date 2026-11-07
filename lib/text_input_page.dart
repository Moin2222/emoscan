import 'package:flutter/material.dart';
import 'model_handler.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class TextInputPage extends StatefulWidget {
  const TextInputPage({super.key});

  @override
  State<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends State<TextInputPage> {
  final TextEditingController _textController = TextEditingController();
  final ModelHandler _modelHandler = ModelHandler();
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      logger.i("Loading models...");
      await _modelHandler.loadModels();
      logger.i("Models loaded successfully");
      if (mounted) {
        setState(() {
          _modelLoaded = true;
        });
      }
    } catch (e) {
      logger.e("Error loading models: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load models: $e')),
        );
      }
    }
  }

  Future<void> _predictAndShow(String text) async {
    if (!_modelLoaded) {
      logger.w("Model not loaded yet.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model is not ready yet. Please wait...')),
      );
      return;
    }

    try {
      logger.i("Running prediction for input: $text");
      final results = await _modelHandler.predictAll(text);
      logger.i("Prediction result: $results");

      if (!mounted) return;

      List<double> emojiOutput = results['emoji'];
      List<String> emojis = [
        '😊', '😔', '😤', '😃', '😮', '😐', '😨', '😡',
        '🤗', '🙁', '😱', '🤬', '😁', '😅', '😢', '😎', '😞', '🥳', '😭',
      ];

      if (emojiOutput.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No emoji prediction found.')),
        );
        return;
      }

      int emojiIndex = emojiOutput.indexOf(emojiOutput.reduce((a, b) => a > b ? a : b));
      String emoji = emojis[emojiIndex % emojis.length];

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Text Analyzed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Predicted Emoji:', style: TextStyle(fontSize: 18)),
              Center(child: Text(emoji, style: const TextStyle(fontSize: 50))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      logger.e("Prediction failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prediction failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _modelHandler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EmoScan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset('assets/images/welcome_emoji.png', height: 150),
            const SizedBox(height: 20),
            const Spacer(),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'Enter your text here',
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                logger.i("Submit button pressed");
                String inputText = _textController.text.trim();

                if (inputText.isEmpty) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter some text!')),
                  );
                  return;
                }

                await _predictAndShow(inputText);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Submit', style: TextStyle(fontSize: 18, color: Colors.black)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
