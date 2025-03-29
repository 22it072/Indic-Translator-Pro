import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/language_utils.dart';

class LanguagePickerDialog extends StatelessWidget {
  final String currentLanguage;

  const LanguagePickerDialog({
    Key? key,
    required this.currentLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get languages directly from AppConstants instead of LanguageUtils
    final languages = AppConstants.indianLanguages;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Text(
            'Select Language',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      language['flag']!,  // Get flag directly from the map
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(language['name']!),  // Get name directly from the map
                  trailing: language['code'] == currentLanguage
                      ? Icon(Icons.check, color: theme.primaryColor)
                      : null,
                  onTap: () {
                    Navigator.pop(context, language['code']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}