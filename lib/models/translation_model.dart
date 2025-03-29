class Translation {
  final String original;
  final String translated;
  final String fromLanguage;
  final String toLanguage;
  final int timestamp;
  final bool isFavorite;

  Translation({
    required this.original,
    required this.translated,
    required this.fromLanguage,
    required this.toLanguage,
    required this.timestamp,
    this.isFavorite = false,
  });

  Translation copyWith({
    String? original,
    String? translated,
    String? fromLanguage,
    String? toLanguage,
    int? timestamp,
    bool? isFavorite,
  }) {
    return Translation(
      original: original ?? this.original,
      translated: translated ?? this.translated,
      fromLanguage: fromLanguage ?? this.fromLanguage,
      toLanguage: toLanguage ?? this.toLanguage,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
    'original': original,
    'translated': translated,
    'fromLanguage': fromLanguage,
    'toLanguage': toLanguage,
    'timestamp': timestamp,
    'isFavorite': isFavorite,
  };

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
    original: json['original'],
    translated: json['translated'],
    fromLanguage: json['fromLanguage'],
    toLanguage: json['toLanguage'],
    timestamp: json['timestamp'],
    isFavorite: json['isFavorite'] ?? false,
  );
}