import 'package:flutter/material.dart';

class TranslationArrows extends StatelessWidget {
  final bool isTranslating;
  final Animation<double> pulseAnimation;
  final VoidCallback onTranslatePressed;

  const TranslationArrows({
    Key? key,
    required this.isTranslating,
    required this.pulseAnimation,
    required this.onTranslatePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return isTranslating
                ? Transform.scale(
              scale: pulseAnimation.value,
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
              onPressed: onTranslatePressed,
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
                  Text('Translate',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: Colors.white)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}