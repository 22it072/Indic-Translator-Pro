import 'package:translator/translator.dart';

class TranslationService {
  final translator = GoogleTranslator();

  Future<String> translateText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    try {
      final translation = await translator.translate(
        text,
        from: fromLanguage,
        to: toLanguage,
      );
      return translation.text;
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }
}