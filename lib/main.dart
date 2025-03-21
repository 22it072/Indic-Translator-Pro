// File: lib/main.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indic Translator Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w700),
          displayMedium: TextStyle(fontWeight: FontWeight.w700),
          displaySmall: TextStyle(fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6200EA), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstTime = prefs.getBool('first_time') ?? true;

    setState(() {
      _isFirstTime = firstTime;
    });

    if (!_isFirstTime) {
      Future.delayed(const Duration(seconds: 2), () {
        _navigateToHome();
      });
    }
  }

  Future<void> _setFirstTimeDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const TranslatorScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.9),
              theme.colorScheme.tertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _animation,
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.translate_rounded,
                              size: 70,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeTransition(
                        opacity: _animation,
                        child: Text(
                          'Indic Translator Pro',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _animation,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Translate between 22 Indian languages and English with ease',
                              textStyle: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              speed: const Duration(milliseconds: 50),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          totalRepeatCount: 1,
                        ),
                      ),
                      const SizedBox(height: 80),
                      _isFirstTime ? _buildFeaturesList(theme) : const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),
              ),
              if (_isFirstTime)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _animation,
                    child: ElevatedButton(
                      onPressed: () {
                        _setFirstTimeDone();
                        _navigateToHome();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                        minimumSize: Size(size.width, 56),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 4,
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(ThemeData theme) {
    final features = [
      {'icon': Icons.record_voice_over, 'text': 'Voice recognition in multiple languages'},
      {'icon': Icons.volume_up, 'text': 'Natural voice output for translated text'},
      {'icon': Icons.speed, 'text': 'Fast and accurate translations'},
      {'icon': Icons.memory, 'text': 'Save and recall your translation history'},
    ];

    return FadeTransition(
      opacity: _animation,
      child: Column(
        children: [
          for (var feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      feature['text'] as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({Key? key}) : super(key: key);

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final translator = GoogleTranslator();
  final PageController _pageController = PageController();

  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isPlaying = false;
  bool _showFavorites = false;
  int _currentPage = 0;

  String _recognizedText = '';
  String _translatedText = '';

  String _fromLanguage = 'en';
  String _toLanguage = 'hi';

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  List<Map<String, dynamic>> _recentTranslations = [];
  List<Map<String, dynamic>> _favoriteTranslations = [];

  // Updated TTS locale mapping
  final Map<String, String> _languageToTtsLocale = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'bn': 'bn-IN',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'mr': 'mr-IN',
    'gu': 'gu-IN',
    'kn': 'kn-IN',
    'ml': 'ml-IN',
    'pa': 'pa-IN',
    'or': 'or-IN',
    'as': 'as-IN', // Assamese
    'ur': 'ur-IN', // Urdu
    'sa': 'sa-IN', // Sanskrit
    'ne': 'ne-NP', // Nepali
    'sd': 'sd-IN', // Sindhi
    'kok': 'kok-IN', // Konkani
    'mai': 'mai-IN', // Maithili
    'bho': 'bho-IN', // Bhojpuri
    'doi': 'doi-IN', // Dogri
    'sat': 'sat-IN', // Santali
    'mni': 'mni-IN', // Manipuri
  };

  // Updated speech recognition locale mapping
  final Map<String, String> _languageToSpeechLocale = {
    'en': 'en_US',
    'hi': 'hi_IN',
    'bn': 'bn_IN',
    'ta': 'ta_IN',
    'te': 'te_IN',
    'mr': 'mr_IN',
    'gu': 'gu_IN',
    'kn': 'kn_IN',
    'ml': 'ml_IN',
    'pa': 'pa_IN',
    'or': 'or_IN',
    'as': 'as_IN', // Assamese
    'ur': 'ur_IN', // Urdu
    'sa': 'sa_IN', // Sanskrit
    'ne': 'ne_NP', // Nepali
    'sd': 'sd_IN', // Sindhi
    'kok': 'kok_IN', // Konkani
    'mai': 'mai_IN', // Maithili
    'bho': 'bho_IN', // Bhojpuri
    'doi': 'doi_IN', // Dogri
    'sat': 'sat_IN', // Santali
    'mni': 'mni_IN', // Manipuri
  };

  // Updated language list with more Indian languages
  final List<Map<String, String>> _indianLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳'},
    {'code': 'bn', 'name': 'Bengali', 'flag': '🇮🇳'},
    {'code': 'ta', 'name': 'Tamil', 'flag': '🇮🇳'},
    {'code': 'te', 'name': 'Telugu', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'Marathi', 'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'Gujarati', 'flag': '🇮🇳'},
    {'code': 'kn', 'name': 'Kannada', 'flag': '🇮🇳'},
    {'code': 'ml', 'name': 'Malayalam', 'flag': '🇮🇳'},
    {'code': 'pa', 'name': 'Punjabi', 'flag': '🇮🇳'},
    {'code': 'or', 'name': 'Odia', 'flag': '🇮🇳'},
    {'code': 'as', 'name': 'Assamese', 'flag': '🇮🇳'},
    {'code': 'ur', 'name': 'Urdu', 'flag': '🇮🇳'},
    {'code': 'sa', 'name': 'Sanskrit', 'flag': '🇮🇳'},
    {'code': 'ne', 'name': 'Nepali', 'flag': '🇮🇳'},
    {'code': 'sd', 'name': 'Sindhi', 'flag': '🇮🇳'},
    {'code': 'kok', 'name': 'Konkani', 'flag': '🇮🇳'},
    {'code': 'mai', 'name': 'Maithili', 'flag': '🇮🇳'},
    {'code': 'bho', 'name': 'Bhojpuri', 'flag': '🇮🇳'},
    {'code': 'doi', 'name': 'Dogri', 'flag': '🇮🇳'},
    {'code': 'sat', 'name': 'Santali', 'flag': '🇮🇳'},
    {'code': 'mni', 'name': 'Manipuri', 'flag': '🇮🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _loadRecentTranslations();
    _loadFavoriteTranslations();
    _loadLastUsedLanguages();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);

    _pageController.addListener(() {
      if (_pageController.page!.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  Future<void> _loadLastUsedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fromLanguage = prefs.getString('from_language') ?? 'en';
      _toLanguage = prefs.getString('to_language') ?? 'hi';
    });
  }

  Future<void> _saveLastUsedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('from_language', _fromLanguage);
    await prefs.setString('to_language', _toLanguage);
  }

  Future<void> _loadRecentTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final recentJson = prefs.getString('recent_translations');

    if (recentJson != null) {
      try {
        final List<dynamic> decoded = await jsonDecode(recentJson);
        setState(() {
          _recentTranslations = List<Map<String, dynamic>>.from(decoded);
        });
      } catch (e) {
        debugPrint('Error loading recent translations: $e');
      }
    }
  }

  Future<void> _saveRecentTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final recentJson = jsonEncode(_recentTranslations);
    await prefs.setString('recent_translations', recentJson);
  }

  Future<void> _loadFavoriteTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorite_translations');

    if (favoritesJson != null) {
      try {
        final List<dynamic> decoded = await jsonDecode(favoritesJson);
        setState(() {
          _favoriteTranslations = List<Map<String, dynamic>>.from(decoded);
        });
      } catch (e) {
        debugPrint('Error loading favorite translations: $e');
      }
    }
  }

  Future<void> _saveFavoriteTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(_favoriteTranslations);
    await prefs.setString('favorite_translations', favoritesJson);
  }

  void _addToRecentTranslations() {
    if (_recognizedText.isEmpty || _translatedText.isEmpty) return;

    final translation = {
      'original': _recognizedText,
      'translated': _translatedText,
      'fromLanguage': _fromLanguage,
      'toLanguage': _toLanguage,
      'timestamp': DateTime
          .now()
          .millisecondsSinceEpoch,
      'isFavorite': false,
    };

    // Remove duplicates and keep list at max 20 items
    _recentTranslations.removeWhere(
            (item) =>
        item['original'] == _recognizedText &&
            item['fromLanguage'] == _fromLanguage &&
            item['toLanguage'] == _toLanguage
    );

    _recentTranslations.insert(0, translation);

    if (_recentTranslations.length > 20) {
      _recentTranslations = _recentTranslations.sublist(0, 20);
    }

    _saveRecentTranslations();
  }

  void _toggleFavorite(Map<String, dynamic> translation) {
    bool isFavorite = translation['isFavorite'] ?? false;

    if (isFavorite) {
      // Remove from favorites
      _favoriteTranslations.removeWhere(
              (item) =>
          item['original'] == translation['original'] &&
              item['fromLanguage'] == translation['fromLanguage'] &&
              item['toLanguage'] == translation['toLanguage']
      );
    } else {
      // Add to favorites
      final favorite = Map<String, dynamic>.from(translation);
      favorite['isFavorite'] = true;

      // Remove duplicates
      _favoriteTranslations.removeWhere(
              (item) =>
          item['original'] == translation['original'] &&
              item['fromLanguage'] == translation['fromLanguage'] &&
              item['toLanguage'] == translation['toLanguage']
      );

      _favoriteTranslations.insert(0, favorite);
    }

    // Update the recent list
    for (var i = 0; i < _recentTranslations.length; i++) {
      if (_recentTranslations[i]['original'] == translation['original'] &&
          _recentTranslations[i]['fromLanguage'] ==
              translation['fromLanguage'] &&
          _recentTranslations[i]['toLanguage'] == translation['toLanguage']) {
        _recentTranslations[i]['isFavorite'] = !isFavorite;
      }
    }

    _saveFavoriteTranslations();
    _saveRecentTranslations();

    setState(() {});
  }

  void _useTranslation(Map<String, dynamic> translation) {
    setState(() {
      _fromLanguage = translation['fromLanguage'];
      _toLanguage = translation['toLanguage'];
      _recognizedText = translation['original'];
      _translatedText = translation['translated'];
      _inputController.text = _recognizedText;
      _outputController.text = _translatedText;
    });

    _saveLastUsedLanguages();
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();

    // Get available languages for speech recognition
    if (_speechEnabled) {
      try {
        var availableLocales = await _speechToText.locales();
        debugPrint(
            "Available Speech Recognition Locales: ${availableLocales.map((
                l) => l.localeId).toList()}");
      } catch (e) {
        debugPrint("Failed to get speech locales: $e");
      }
    }

    setState(() {});
  }

  void _initTts() async {
    try {
      await _flutterTts.setLanguage(
          _languageToTtsLocale[_toLanguage] ?? 'en-US');
      await _flutterTts.setSpeechRate(0.5);

      List<dynamic>? languages = await _flutterTts.getLanguages;
      debugPrint("Available TTS Languages: $languages");
    } catch (e) {
      debugPrint("Failed to initialize TTS: $e");
    }

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
      setState(() {
        _isPlaying = false;
      });
    });
  }

  void _startListening() async {
    if (_speechEnabled) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
        _translatedText = '';
      });

      // Use correct locale format for speech recognition
      String localeId = _languageToSpeechLocale[_fromLanguage] ?? 'en_US';

      try {
        await _speechToText.listen(
          onResult: _onSpeechResult,
          localeId: localeId,
          listenMode: ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        );
      } catch (e) {
        debugPrint("Error starting speech recognition: $e");
        _showSnackBar(
            "Could not start speech recognition for ${_getLanguageName(
                _fromLanguage)}");
        setState(() {
          _isListening = false;
        });
      }
    } else {
      _showSnackBar("Speech recognition is not available on this device");
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
      _inputController.text = _recognizedText;
    });

    if (result.finalResult) {
      _translateText(_recognizedText);
    }
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      var translation = await translator.translate(
        text,
        from: _fromLanguage,
        to: _toLanguage,
      );

      setState(() {
        _translatedText = translation.text;
        _outputController.text = _translatedText;
        _isTranslating = false;
      });

      _addToRecentTranslations();
    } catch (e) {
      debugPrint("Translation error: $e");
      setState(() {
        _translatedText = 'Translation error: Please try again';
        _outputController.text = _translatedText;
        _isTranslating = false;
      });
      _showSnackBar(
          "Translation failed. Please check your internet connection.");
    }
  }

  Future<void> _speakTranslatedText() async {
    if (_translatedText.isEmpty) return;

    try {
      if (_isPlaying) {
        await _stopSpeaking();
      }

      String ttsLocale = _languageToTtsLocale[_toLanguage] ?? 'en-US';
      List<dynamic>? availableLanguages = await _flutterTts.getLanguages;

      debugPrint("Attempting to speak in locale: $ttsLocale");
      debugPrint("Available languages: $availableLanguages");

      // Some languages might be available with different locale formats
      bool isLanguageAvailable = false;

      if (availableLanguages != null) {
        // Try exact match
        if (availableLanguages.contains(ttsLocale)) {
          isLanguageAvailable = true;
        }
        // Try matching just the language code
        else {
          String langCode = _toLanguage;
          for (var lang in availableLanguages) {
            if (lang.toString().startsWith(langCode)) {
              ttsLocale = lang.toString();
              isLanguageAvailable = true;
              break;
            }
          }
        }
      }

      if (isLanguageAvailable) {
        await _flutterTts.setLanguage(ttsLocale);
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);

        setState(() {
          _isPlaying = true;
        });

        var result = await _flutterTts.speak(_translatedText);

        if (result != 1) {
          setState(() {
            _isPlaying = false;
          });

          _showSnackBar("Failed to speak in ${_getLanguageName(_toLanguage)}");
        }
      } else {
        // Fallback to Google Translate TTS
        _showSnackBar("Text-to-speech not available for ${_getLanguageName(
            _toLanguage)} on this device");
      }
    } catch (e) {
      debugPrint("TTS Error: $e");
      setState(() {
        _isPlaying = false;
      });

      _showSnackBar("Text-to-speech error: Please try again");
    }
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  String _getLanguageName(String code) {
    final language = _indianLanguages.firstWhere(
          (lang) => lang['code'] == code,
      orElse: () => {'code': code, 'name': code, 'flag': '🌐'},
    );
    return language['name'] ?? code;
  }

  String _getLanguageFlag(String code) {
    final language = _indianLanguages.firstWhere(
          (lang) => lang['code'] == code,
      orElse: () => {'code': code, 'name': code, 'flag': '🌐'},
    );
    return language['flag'] ?? '🌐';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _swapLanguages() {
    if (_isListening || _isTranslating || _isPlaying) return;

    setState(() {
      final temp = _fromLanguage;
      _fromLanguage = _toLanguage;
      _toLanguage = temp;

      final tempText = _recognizedText;
      _recognizedText = _translatedText;
      _translatedText = tempText;

      _inputController.text = _recognizedText;
      _outputController.text = _translatedText;
    });

    _saveLastUsedLanguages();
  }

  void _clearTexts() {
    setState(() {
      _recognizedText = '';
      _translatedText = '';
      _inputController.clear();
      _outputController.clear();
    });
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied to clipboard');
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    _inputController.dispose();
    _outputController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentPage == 0
              ? 'Indic Translator Pro'
              : _showFavorites ? 'Favorites' : 'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              // Show settings dialog with advanced options
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildTranslatorPage(theme, size),
          _buildHistoryPage(theme),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: 'Translate',
          ),
          BottomNavigationBarItem(
            icon: Icon(_showFavorites ? Icons.favorite : Icons.history),
            label: _showFavorites ? 'Favorites' : 'History',
          ),
        ],
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildTranslatorPage(ThemeData theme, Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language Selection Row
            _buildLanguageSelectionRow(theme),

            const SizedBox(height: 24),

            // Source Text Card
            _buildSourceTextCard(theme),

            const SizedBox(height: 16),

            // Translation arrows
            _buildTranslationArrows(theme),

            const SizedBox(height: 16),

            // Translated Text Card
            _buildTranslatedTextCard(theme),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(theme, size),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelectionRow(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            // From Language
            Expanded(
              child: InkWell(
                onTap: () => _showLanguagePickerDialog(true),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getLanguageFlag(_fromLanguage),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getLanguageName(_fromLanguage),
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Swap Button
            IconButton(
              onPressed: _swapLanguages,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horiz,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),

            // To Language
            Expanded(
              child: InkWell(
                onTap: () => _showLanguagePickerDialog(false),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getLanguageFlag(_toLanguage),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getLanguageName(_toLanguage),
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTextCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Original Text (${_getLanguageName(_fromLanguage)})',
                  style: theme.textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _clearTexts,
                      icon: const Icon(Icons.clear, size: 20),
                      tooltip: 'Clear',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _recognizedText.isNotEmpty
                          ? () => _copyToClipboard(_recognizedText)
                          : null,
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copy',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter text or tap microphone to speak...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (text) {
                setState(() {
                  _recognizedText = text;
                });
              },
              onSubmitted: _translateText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationArrows(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return _isTranslating
                ? Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            )
                : ElevatedButton(
              onPressed: () => _translateText(_recognizedText),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.translate, size: 20),
                  const SizedBox(width: 8),
                  Text('Translate', style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTranslatedTextCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Translated Text (${_getLanguageName(_toLanguage)})',
                  style: theme.textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _translatedText.isNotEmpty
                          ? () {
                        // Add to favorites (toggle)
                        final translation = {
                          'original': _recognizedText,
                          'translated': _translatedText,
                          'fromLanguage': _fromLanguage,
                          'toLanguage': _toLanguage,
                          'timestamp': DateTime
                              .now()
                              .millisecondsSinceEpoch,
                        };

                        _toggleFavorite(translation);
                      }
                          : null,
                      icon: Icon(
                        _favoriteTranslations.any((item) =>
                        item['original'] == _recognizedText &&
                            item['fromLanguage'] == _fromLanguage &&
                            item['toLanguage'] == _toLanguage
                        ) ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _favoriteTranslations.any((item) =>
                        item['original'] == _recognizedText &&
                            item['fromLanguage'] == _fromLanguage &&
                            item['toLanguage'] == _toLanguage
                        ) ? Colors.red : null,
                      ),
                      tooltip: 'Add to favorites',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _translatedText.isNotEmpty
                          ? () => _copyToClipboard(_translatedText)
                          : null,
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copy',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _translatedText.isEmpty
                  ? Text(
                'Translation will appear here',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              )
                  : SelectableText(
                _translatedText,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Microphone button
        GestureDetector(
          onTapDown: (_) => _startListening(),
          onTapUp: (_) => _stopListening(),
          onTapCancel: () => _stopListening(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: _isListening
                  ? theme.colorScheme.primary.withOpacity(0.8)
                  : theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _isListening
                      ? theme.colorScheme.primary.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.3),
                  spreadRadius: _isListening ? 4 : 1,
                  blurRadius: _isListening ? 8 : 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.white : theme.colorScheme
                          .primary,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // TTS button
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: _isPlaying
                ? theme.colorScheme.primary.withOpacity(0.8)
                : theme.colorScheme.secondaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _isPlaying
                    ? theme.colorScheme.primary.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
                spreadRadius: _isPlaying ? 4 : 1,
                blurRadius: _isPlaying ? 8 : 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _isPlaying ? _stopSpeaking : _speakTranslatedText,
            icon: Icon(
              _isPlaying ? Icons.stop : Icons.volume_up,
              color: _isPlaying ? Colors.white : theme.colorScheme.primary,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryPage(ThemeData theme) {
    final List<Map<String, dynamic>> displayList =
    _showFavorites ? _favoriteTranslations : _recentTranslations;

    return Column(
      children: [
        // Toggle button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Switch(
                value: _showFavorites,
                onChanged: (value) {
                  setState(() {
                    _showFavorites = value;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
              Text(
                'Show Favorites',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),

        // History list
        Expanded(
          child: displayList.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showFavorites ? Icons.favorite_border : Icons.history,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _showFavorites
                      ? 'No favorite translations yet'
                      : 'No recent translations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _showFavorites
                      ? 'Your favorite translations will appear here'
                      : 'Your recent translations will appear here',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final item = displayList[index];
                final bool isFavorite = item['isFavorite'] ?? false;

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isFavorite
                                ? Colors.amber.shade200
                                : Colors.transparent,
                            width: isFavorite ? 1.5 : 0,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _useTranslation(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${_getLanguageFlag(
                                            item['fromLanguage'])} ${_getLanguageName(
                                            item['fromLanguage'])} → ${_getLanguageFlag(
                                            item['toLanguage'])} ${_getLanguageName(
                                            item['toLanguage'])}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () => _toggleFavorite(item),
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons
                                            .favorite_border,
                                        size: 20,
                                        color: isFavorite ? Colors.red : null,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item['original'],
                                  style: theme.textTheme.bodyLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(height: 24),
                                Text(
                                  item['translated'],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    _formatTimestamp(item['timestamp']),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1
          ? 'day'
          : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1
          ? 'hour'
          : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1
          ? 'minute'
          : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showLanguagePickerDialog(bool isFromLanguage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isFromLanguage
                        ? 'Select Source Language'
                        : 'Select Target Language',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _indianLanguages.length,
                  itemBuilder: (context, index) {
                    final language = _indianLanguages[index];
                    final isSelected = isFromLanguage
                        ? language['code'] == _fromLanguage
                        : language['code'] == _toLanguage;

                    return Card(
                      elevation: 0,
                      color: isSelected
                          ? Theme
                          .of(context)
                          .colorScheme
                          .secondaryContainer
                          : null,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Text(
                          language['flag'] ?? '🌐',
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(language['name'] ?? ''),
                        trailing: isSelected
                            ? Icon(
                          Icons.check_circle,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                        )
                            : null,
                        onTap: () {
                          if (isFromLanguage) {
                            setState(() {
                              _fromLanguage = language['code'] ?? 'en';
                            });
                          } else {
                            setState(() {
                              _toLanguage = language['code'] ?? 'hi';
                            });
                          }

                          _saveLastUsedLanguages();
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Settings', style: theme.textTheme.titleLarge),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Clear Translation History'),
                  onTap: () {
                    Navigator.pop(context);
                    _showConfirmationDialog(
                      title: 'Clear History',
                      content: 'Are you sure you want to clear all your translation history?',
                      onConfirm: () {
                        setState(() {
                          _recentTranslations = [];
                        });
                        _saveRecentTranslations();
                        _showSnackBar('Translation history cleared');
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Clear Favorites'),
                  onTap: () {
                    Navigator.pop(context);
                    _showConfirmationDialog(
                      title: 'Clear Favorites',
                      content: 'Are you sure you want to clear all your favorite translations?',
                      onConfirm: () {
                        setState(() {
                          _favoriteTranslations = [];
                        });
                        _saveFavoriteTranslations();
                        _showSnackBar('Favorites cleared');
                      },
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Indic Translator Pro'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

//half cut
  void _showAboutDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('About Indic Translator Pro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Indic Translator Pro helps you translate between 22 Indian languages and English with voice input, text-to-speech, and offline history storage.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.translate, size: 20),
                  const SizedBox(width: 8),
                  Text('Real-time voice and text translation',
                      style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.volume_up, size: 20),
                  const SizedBox(width: 8),
                  Text('Text-to-speech with natural voice output',
                      style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.history, size: 20),
                  const SizedBox(width: 8),
                  Text('Recent translations and favorites',
                      style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Developed with ❤️ using Flutter.',
                style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
