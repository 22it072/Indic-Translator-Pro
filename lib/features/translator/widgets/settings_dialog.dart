import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  final VoidCallback onClearHistory;
  final VoidCallback onClearFavorites;

  const SettingsDialog({
    Key? key,
    required this.onClearHistory,
    required this.onClearFavorites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Clear History'),
            onTap: () {
              Navigator.pop(context);
              onClearHistory();
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Clear Favorites'),
            onTap: () {
              Navigator.pop(context);
              onClearFavorites();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}