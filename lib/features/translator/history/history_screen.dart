import 'package:flutter/material.dart';
import '../../../models/translation_model.dart';
import 'translation_item.dart';
import 'widgets/empty_history.dart';

class HistoryScreen extends StatelessWidget {
  final List<Translation> translations;
  final bool showFavorites;
  final Function(Translation) onToggleFavorite;
  final Function(Translation) onUseTranslation;
  final Function(bool) onToggleView;

  const HistoryScreen({
    Key? key,
    required this.translations,
    required this.showFavorites,
    required this.onToggleFavorite,
    required this.onUseTranslation,
    required this.onToggleView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Toggle button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Switch(
                value: showFavorites,
                onChanged: onToggleView,
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
          child: translations.isEmpty
              ? EmptyHistory(showFavorites: showFavorites)
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: translations.length,
            itemBuilder: (context, index) {
              final translation = translations[index];
              return TranslationItem(
                translation: translation,
                onToggleFavorite: () => onToggleFavorite(translation),
                onUseTranslation: () => onUseTranslation(translation),
              );
            },
          ),
        ),
      ],
    );
  }
}