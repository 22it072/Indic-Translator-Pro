import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    await _tts.setSpeechRate(0.5);
    _tts.setCompletionHandler(() {});
    _tts.setErrorHandler((msg) {});
    _isInitialized = true;
  }

  Future<void> speak({
    required String text,
    required String language,
    required VoidCallback onComplete,
  }) async {
    if (!_isInitialized) return;

    await _tts.setLanguage(language);
    await _tts.speak(text);
    _tts.setCompletionHandler(onComplete);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}