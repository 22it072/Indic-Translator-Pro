import 'package:flutter/material.dart';

class FeaturesList extends StatelessWidget {
  final Animation<double> animation;

  const FeaturesList({Key? key, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final features = [
      {'icon': Icons.record_voice_over, 'text': 'Voice recognition in multiple languages'},
      {'icon': Icons.volume_up, 'text': 'Natural voice output for translated text'},
      {'icon': Icons.speed, 'text': 'Fast and accurate translations'},
      {'icon': Icons.memory, 'text': 'Save and recall your translation history'},
    ];

    return FadeTransition(
      opacity: animation,
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