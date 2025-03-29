import 'package:flutter/material.dart';

class EmptyHistory extends StatelessWidget {
  final bool showFavorites;

  const EmptyHistory({
    Key? key,
    required this.showFavorites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showFavorites ? Icons.favorite_border : Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            showFavorites
                ? 'No favorite translations yet'
                : 'No recent translations',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showFavorites
                ? 'Your favorite translations will appear here'
                : 'Your recent translations will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}