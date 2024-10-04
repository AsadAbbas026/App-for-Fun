import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funny Virtual Assistant',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VoiceAssistantScreen(),
    );
  }
}

class VoiceAssistantScreen extends StatefulWidget {
  @override
  _VoiceAssistantScreenState createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late stt.SpeechToText speech;
  late FlutterTts flutterTts;
  bool _isListening = false;
  String _lastCommand = "";

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    flutterTts = FlutterTts();
  }

  void _startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      speech.listen(onResult: (result) {
        setState(() {
          _lastCommand = result.recognizedWords;
        });
        if (result.hasConfidenceRating && result.confidence > 0.5) {
          _handleCommand(result.recognizedWords);
        }
      });
    }
  }

  void _stopListening() {
    speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _handleCommand(String command) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.12:5000/ask'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'question': command,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      String assistantResponse = jsonResponse['response'];
      _speak(assistantResponse);
    } else {
      _speak("Sorry, I couldn't process that.");
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Funny Virtual Assistant')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isListening ? 'Listening...' : 'Say something funny!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              _lastCommand,
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}
