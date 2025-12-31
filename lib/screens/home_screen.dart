import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _responseText = '';
  bool _isLoading = false;

  late final GenerativeModel model;
  @override
  void initState() {
    super.initState();

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY tidak ditemukan');
    }

    model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
  }

  Future<void> sendPrompt() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _responseText = '';
    });

    try {
      final content = [
        Content.text(
          "Saya sedang merasa ${_controller.text}. Tolong beri motivasi singkat.",
        ),
      ];

      final response = await model.generateContent(content);

      setState(() {
        _responseText = response.text ?? 'AI tidak memberikan jawaban.';
      });
    } catch (e) {
      setState(() {
        _responseText = 'Terjadi error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MoodMate AI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tulis perasaan kamu...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : sendPrompt,
              child: const Text('Kirim'),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(_responseText),
          ],
        ),
      ),
    );
  }
}
