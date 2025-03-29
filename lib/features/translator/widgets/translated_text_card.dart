import 'package:flutter/material.dart';

class TranslatedTextCard extends StatelessWidget {
  final String languageName;
  final String translatedText;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onCopyPressed;

  const TranslatedTextCard({
    Key? key,
    required this.languageName,
    required this.translatedText,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onCopyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  'Translated Text ($languageName)',
                  style: theme.textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: translatedText.isNotEmpty ? onFavoritePressed : null,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFavorite ? Colors.red : null,
                      ),
                      tooltip: 'Add to favorites',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: translatedText.isNotEmpty ? onCopyPressed : null,
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
              child: translatedText.isEmpty
                  ? Text(
                'Translation will appear here',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              )
                  : SelectableText(
                translatedText,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}