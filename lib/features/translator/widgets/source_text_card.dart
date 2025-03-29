import 'package:flutter/material.dart';

class SourceTextCard extends StatelessWidget {
  final String languageName;
  final TextEditingController controller;
  final String recognizedText;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onClearPressed;
  final VoidCallback onCopyPressed;
  final ValueChanged<String> onSubmit;

  const SourceTextCard({
    Key? key,
    required this.languageName,
    required this.controller,
    required this.recognizedText,
    required this.onTextChanged,
    required this.onClearPressed,
    required this.onCopyPressed,
    required this.onSubmit,
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
                  'Original Text ($languageName)',
                  style: theme.textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onClearPressed,
                      icon: const Icon(Icons.clear, size: 20),
                      tooltip: 'Clear',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: recognizedText.isNotEmpty ? onCopyPressed : null,
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
              controller: controller,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter text or tap microphone to speak...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: onTextChanged,
              onSubmitted: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}