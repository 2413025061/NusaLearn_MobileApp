import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHighScore = 'nusalearn_high_score';
  static const String _keyTotalQuizPlayed = 'nusalearn_total_quiz_played';
  static const String _keyLastScore = 'nusalearn_last_score';

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
}
