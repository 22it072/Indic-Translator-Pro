import 'package:flutter/material.dart';
import '../../../../utils/language_utils.dart';

class LanguageSelectionRow extends StatelessWidget {
  final String fromLanguage;
  final String toLanguage;
  final VoidCallback onFromLanguagePressed;
  final VoidCallback onToLanguagePressed;
  final VoidCallback onSwapPressed;

  const LanguageSelectionRow({
    Key? key,
    required this.fromLanguage,
    required this.toLanguage,
    required this.onFromLanguagePressed,
    required this.onToLanguagePressed,
    required this.onSwapPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                onTap: onFromLanguagePressed,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LanguageUtils.getLanguageFlag(fromLanguage),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          LanguageUtils.getLanguageName(fromLanguage),
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
              onPressed: onSwapPressed,
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
                onTap: onToLanguagePressed,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LanguageUtils.getLanguageFlag(toLanguage),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          LanguageUtils.getLanguageName(toLanguage),
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
}