import 'constants.dart';

class LanguageUtils {
  static String getLanguageName(String code) {
    final language = AppConstants.indianLanguages.firstWhere(
          (lang) => lang['code'] == code,
      orElse: () => {'code': code, 'name': code, 'flag': '🌐'},
    );
    return language['name'] ?? code;
  }

  static String getLanguageFlag(String code) {
    final language = AppConstants.indianLanguages.firstWhere(
          (lang) => lang['code'] == code,
      orElse: () => {'code': code, 'name': code, 'flag': '🌐'},
    );
    return language['flag'] ?? '🌐';
  }

  static String getTtsLocale(String languageCode) {
    return AppConstants.languageToTtsLocale[languageCode] ?? 'en-US';
  }

  static String getSpeechLocale(String languageCode) {
    return AppConstants.languageToSpeechLocale[languageCode] ?? 'en_US';
  }
}