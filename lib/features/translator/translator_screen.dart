import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart' hide Translation;

import '../../models/translation_model.dart';
import '../../app/theme/theme_provider.dart';
import '../../services/translation_service.dart';
import '../../services/speech_service.dart';
import '../../services/tts_service.dart';
import '../../services/storage_service.dart';
import '../../utils/language_utils.dart';
import '../../utils/time_utils.dart';

import 'widgets/language_selection_row.dart';
import 'widgets/source_text_card.dart';
import 'widgets/translated_text_card.dart';
import 'widgets/translation_arrows.dart';
import 'widgets/action_buttons.dart';
import 'widgets/theme_toggle_button.dart';
import 'widgets/language_picker_dialog.dart';
import 'widgets/settings_dialog.dart';
import 'history/history_screen.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({Key? key}) : super(key: key);

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen>
    with SingleTickerProviderStateMixin {
  final TranslationService _translationService = TranslationService();
  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();
  final StorageService _storageService = StorageService();

  final PageController _pageController = PageController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  bool _isListening = false;
  bool _isTranslating = false;
  bool _isPlaying = false;
  bool _showFavorites = false;
  int _currentPage = 0;

  String _recognizedText = '';
  String _translatedText = '';
  String _fromLanguage = 'en';
  String _toLanguage = 'hi';

  List<Translation> _recentTranslations = [];
  List<Translation> _favoriteTranslations = [];

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadData();
    _pageController.addListener(_handlePageChange);
  }

  void _initAnimation() {
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
  }

  void _handlePageChange() {
    if (_pageController.page?.round() != _currentPage) {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    }
  }

  Future<void> _loadData() async {
    await _speechService.initialize();
    await _ttsService.initialize();
    await _loadLastUsedLanguages();
    await _loadRecentTranslations();
    await _loadFavoriteTranslations();
  }

  Future<void> _loadLastUsedLanguages() async {
    final languages = await _storageService.getLastUsedLanguages();
    setState(() {
      _fromLanguage = languages['from'] ?? 'en';
      _toLanguage = languages['to'] ?? 'hi';
    });
  }

  Future<void> _saveLastUsedLanguages() async {
    await _storageService.saveLastUsedLanguages(_fromLanguage, _toLanguage);
  }

  Future<void> _loadRecentTranslations() async {
    final translations = await _storageService.getRecentTranslations();
    setState(() {
      _recentTranslations = translations;
    });
  }

  Future<void> _saveRecentTranslations() async {
    await _storageService.saveRecentTranslations(_recentTranslations);
  }

  Future<void> _loadFavoriteTranslations() async {
    final translations = await _storageService.getFavoriteTranslations();
    setState(() {
      _favoriteTranslations = translations;
    });
  }

  Future<void> _saveFavoriteTranslations() async {
    await _storageService.saveFavoriteTranslations(_favoriteTranslations);
  }

  void _addToRecentTranslations() {
    if (_recognizedText.isEmpty || _translatedText.isEmpty) return;

    final translation = Translation(
      original: _recognizedText,
      translated: _translatedText,
      fromLanguage: _fromLanguage,
      toLanguage: _toLanguage,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    _recentTranslations.removeWhere((item) =>
    item.original == _recognizedText &&
        item.fromLanguage == _fromLanguage &&
        item.toLanguage == _toLanguage);

    _recentTranslations.insert(0, translation);

    if (_recentTranslations.length > 20) {
      _recentTranslations = _recentTranslations.sublist(0, 20);
    }

    _saveRecentTranslations();
  }

  void _toggleFavorite(Translation translation) {
    final isFavorite = translation.isFavorite;

    if (isFavorite) {
      _favoriteTranslations.removeWhere((item) =>
      item.original == translation.original &&
          item.fromLanguage == translation.fromLanguage &&
          item.toLanguage == translation.toLanguage);
    } else {
      final favorite = translation.copyWith(isFavorite: true);
      _favoriteTranslations.removeWhere((item) =>
      item.original == translation.original &&
          item.fromLanguage == translation.fromLanguage &&
          item.toLanguage == translation.toLanguage);
      _favoriteTranslations.insert(0, favorite);
    }

    for (var i = 0; i < _recentTranslations.length; i++) {
      if (_recentTranslations[i].original == translation.original &&
          _recentTranslations[i].fromLanguage == translation.fromLanguage &&
          _recentTranslations[i].toLanguage == translation.toLanguage) {
        _recentTranslations[i] = _recentTranslations[i].copyWith(
          isFavorite: !isFavorite,
        );
      }
    }

    _saveFavoriteTranslations();
    _saveRecentTranslations();
    setState(() {});
  }

  void _useTranslation(Translation translation) {
    setState(() {
      _fromLanguage = translation.fromLanguage;
      _toLanguage = translation.toLanguage;
      _recognizedText = translation.original;
      _translatedText = translation.translated;
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

  Future<void> _startListening() async {
    try {
      setState(() {
        _isListening = true;
        _recognizedText = '';
        _translatedText = '';
      });

      await _speechService.startListening(
        locale: LanguageUtils.getSpeechLocale(_fromLanguage),
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _inputController.text = _recognizedText;
          });

          if (result.finalResult) {
            _translateText(_recognizedText);
          }
        },
      );
    } catch (e) {
      _showSnackBar('Could not start speech recognition');
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final translated = await _translationService.translateText(
        text: text,
        fromLanguage: _fromLanguage,
        toLanguage: _toLanguage,
      );

      setState(() {
        _translatedText = translated;
        _outputController.text = _translatedText;
        _isTranslating = false;
      });

      _addToRecentTranslations();
    } catch (e) {
      setState(() {
        _translatedText = 'Translation error: Please try again';
        _outputController.text = _translatedText;
        _isTranslating = false;
      });
      _showSnackBar('Translation failed. Please check your internet connection.');
    }
  }

  Future<void> _speakTranslatedText() async {
    if (_translatedText.isEmpty) return;

    try {
      setState(() {
        _isPlaying = true;
      });

      await _ttsService.speak(
        text: _translatedText,
        language: _toLanguage,
        onComplete: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isPlaying = false;
      });
      _showSnackBar('Text-to-speech error: Please try again');
    }
  }

  Future<void> _stopSpeaking() async {
    await _ttsService.stop();
    setState(() {
      _isPlaying = false;
    });
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
    _storageService.copyToClipboard(text);
    _showSnackBar('Copied to clipboard');
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

  Future<void> _showLanguagePickerDialog(bool isFromLanguage) async {
    final selectedLanguage = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return LanguagePickerDialog(
          currentLanguage: isFromLanguage ? _fromLanguage : _toLanguage,
        );
      },
    );

    if (selectedLanguage != null) {
      setState(() {
        if (isFromLanguage) {
          _fromLanguage = selectedLanguage;
        } else {
          _toLanguage = selectedLanguage;
        }
      });
      _saveLastUsedLanguages();
    }
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
  void _showAboutDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('About Indic Translator Pro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Indic Translator Pro helps you translate between 22 Indian languages and English with voice input, text-to-speech, and offline history storage.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.translate, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Real-time voice and text translation',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.volume_up, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Text-to-speech with natural voice output',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.history, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Recent translations and favorites',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
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
  @override
  void dispose() {
    _speechService.dispose();
    _ttsService.dispose();
    _inputController.dispose();
    _outputController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentPage == 0
              ? 'Indic Translator Pro'
              : _showFavorites ? 'Favorites' : 'History',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          const ThemeToggleButton(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildTranslatorPage(theme, size),
          HistoryScreen(
            translations: _showFavorites ? _favoriteTranslations : _recentTranslations,
            showFavorites: _showFavorites,
            onToggleFavorite: _toggleFavorite,
            onUseTranslation: _useTranslation,
            onToggleView: (value) => setState(() => _showFavorites = value),
          ),
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
            icon: const Icon(Icons.translate),
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
            LanguageSelectionRow(
              fromLanguage: _fromLanguage,
              toLanguage: _toLanguage,
              onFromLanguagePressed: () => _showLanguagePickerDialog(true),
              onToLanguagePressed: () => _showLanguagePickerDialog(false),
              onSwapPressed: _swapLanguages,
            ),
            const SizedBox(height: 24),
            SourceTextCard(
              languageName: LanguageUtils.getLanguageName(_fromLanguage),
              controller: _inputController,
              recognizedText: _recognizedText,
              onTextChanged: (text) => setState(() => _recognizedText = text),
              onClearPressed: _clearTexts,
              onCopyPressed: () => _copyToClipboard(_recognizedText),
              onSubmit: _translateText,
            ),
            const SizedBox(height: 16),
            TranslationArrows(
              isTranslating: _isTranslating,
              pulseAnimation: _pulseAnimation,
              onTranslatePressed: () => _translateText(_recognizedText),
            ),
            const SizedBox(height: 16),
            TranslatedTextCard(
              languageName: LanguageUtils.getLanguageName(_toLanguage),
              translatedText: _translatedText,
              isFavorite: _favoriteTranslations.any((item) =>
              item.original == _recognizedText &&
                  item.fromLanguage == _fromLanguage &&
                  item.toLanguage == _toLanguage),
              onFavoritePressed: () {
                final translation = Translation(
                  original: _recognizedText,
                  translated: _translatedText,
                  fromLanguage: _fromLanguage,
                  toLanguage: _toLanguage,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                );
                _toggleFavorite(translation);
              },
              onCopyPressed: () => _copyToClipboard(_translatedText),
            ),
            const SizedBox(height: 24),
            ActionButtons(
              isListening: _isListening,
              isPlaying: _isPlaying,
              pulseAnimation: _pulseAnimation,
              onMicPressed: _startListening,
              onMicReleased: _stopListening,
              onSpeakerPressed: _isPlaying ? _stopSpeaking : _speakTranslatedText,
            ),
          ],
        ),
      ),
    );
  }
}