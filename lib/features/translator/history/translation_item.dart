import 'package:flutter/material.dart';
import '../../../models/translation_model.dart';
import '../../../utils/language_utils.dart';
import '../../../utils/time_utils.dart';

class TranslationItem extends StatelessWidget {
  final Translation translation;
  final VoidCallback onToggleFavorite;
  final VoidCallback onUseTranslation;

  const TranslationItem({
    Key? key,
    required this.translation,
    required this.onToggleFavorite,
    required this.onUseTranslation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: translation.isFavorite
              ? Colors.amber.shade200
              : Colors.transparent,
          width: translation.isFavorite ? 1.5 : 0,
        ),
      ),
      child: InkWell(
        onTap: onUseTranslation,
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
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${LanguageUtils.getLanguageFlag(translation.fromLanguage)} '
                          '${LanguageUtils.getLanguageName(translation.fromLanguage)} → '
                          '${LanguageUtils.getLanguageFlag(translation.toLanguage)} '
                          '${LanguageUtils.getLanguageName(translation.toLanguage)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      translation.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 20,
                      color: translation.isFavorite ? Colors.red : null,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                translation.original,
                style: theme.textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 24),
              Text(
                translation.translated,
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
                  TimeUtils.formatTimestamp(translation.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}