import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<void> initialize() async {
    _isInitialized = await _speech.initialize();
  }

  Future<void> startListening({
    required String locale,
    required void Function(SpeechRecognitionResult) onResult,
  }) async {
    if (!_isInitialized) return;

    await _speech.listen(
      onResult: onResult,
      localeId: locale,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  void dispose() {
    _speech.cancel();
  }
}