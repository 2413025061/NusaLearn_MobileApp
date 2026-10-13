import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHighScore = 'nusalearn_high_score';
  static const String _keyTotalQuizPlayed = 'nusalearn_total_quiz_played';
  static const String _keyLastScore = 'nusalearn_last_score';
  static const String _keyLearnedCultures = 'nusalearn_learned_cultures';
  static const String _keyLearnedHeroes = 'nusalearn_learned_heroes';

  // --- KUIS & SKOR ---
  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHighScore) ?? 0;
  }

  static Future<void> saveScore(int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHigh = prefs.getInt(_keyHighScore) ?? 0;
    if (newScore > currentHigh) {
      await prefs.setInt(_keyHighScore, newScore);
    }
    await prefs.setInt(_keyLastScore, newScore);
    
    final playedCount = prefs.getInt(_keyTotalQuizPlayed) ?? 0;
    await prefs.setInt(_keyTotalQuizPlayed, playedCount + 1);
  }

  static Future<int> getTotalQuizPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalQuizPlayed) ?? 0;
  }

  static Future<int> getLastScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastScore) ?? 0;
  }

  // --- PROGRES BELAJAR BUDAYA (PROVINSI) ---
  static Future<Set<String>> getLearnedCultures() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLearnedCultures) ?? [];
    return list.toSet();
  }

  static Future<bool> isCultureLearned(String id) async {
    final set = await getLearnedCultures();
    return set.contains(id);
  }

  static Future<void> markCultureAsLearned(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLearnedCultures) ?? [];
    if (!list.contains(id)) {
      list.add(id);
      await prefs.setStringList(_keyLearnedCultures, list);
    }
  }

  static Future<void> toggleCultureLearned(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLearnedCultures) ?? [];
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await prefs.setStringList(_keyLearnedCultures, list);
  }

  // --- PROGRES BELAJAR PAHLAWAN NASIONAL ---
  static Future<Set<String>> getLearnedHeroes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLearnedHeroes) ?? [];
    return list.toSet();
  }

  static Future<bool> isHeroLearned(String id) async {
    final set = await getLearnedHeroes();
    return set.contains(id);
  }

  static Future<void> markHeroAsLearned(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLearnedHeroes) ?? [];
    if (!list.contains(id)) {
      list.add(id);
      await prefs.setStringList(_keyLearnedHeroes, list);
    }
  }

  static Future<void> toggleHeroLearned(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLearnedHeroes) ?? [];
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await prefs.setStringList(_keyLearnedHeroes, list);
  }

  // --- RESET PROGRES ---
  static Future<void> resetLearningProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLearnedCultures);
    await prefs.remove(_keyLearnedHeroes);
  }
}
