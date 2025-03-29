import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../models/translation_model.dart';

class StorageService {
  Future<void> saveLastUsedLanguages(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('from_language', from);
    await prefs.setString('to_language', to);
  }

  Future<Map<String, String>> getLastUsedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'from': prefs.getString('from_language') ?? 'en',
      'to': prefs.getString('to_language') ?? 'hi',
    };
  }

  Future<void> saveRecentTranslations(List<Translation> translations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = translations.map((t) => t.toJson()).toList();
    await prefs.setString('recent_translations', json.encode(jsonList));
  }

  Future<List<Translation>> getRecentTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('recent_translations');
    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((item) => Translation.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFavoriteTranslations(List<Translation> translations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = translations.map((t) => t.toJson()).toList();
    await prefs.setString('favorite_translations', json.encode(jsonList));
  }

  Future<List<Translation>> getFavoriteTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('favorite_translations');
    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((item) => Translation.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearRecentTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_translations');
  }

  Future<void> clearFavoriteTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorite_translations');
  }

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}