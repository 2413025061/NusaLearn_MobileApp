import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _resultPlayer = AudioPlayer();

  static Future<void> init() async {
    try {
      await _clickPlayer.setPlayerMode(PlayerMode.lowLatency);
    } catch (_) {
      // Ignore if lowLatency mode unsupported on specific platform
    }
  }

  /// Memainkan sound effect saat klik tombol jawaban kuis
  static Future<void> playClick() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource('sounds/quiz_click.wav'));
    } catch (_) {}
  }

  /// Memainkan sound effect berdasarkan skor kuis:
  /// - Nilai 100: Sound yang lebih menyenangkan lagi (triumphant / grand fanfare)
  /// - Nilai 70 - 90: Sound ceria
  /// - Nilai 50 - 60: Sound flat
  /// - Nilai 0 - 40: Sound sedih
  static Future<void> playQuizResult(int score) async {
    try {
      await _resultPlayer.stop();
      if (score == 100) {
        await _resultPlayer.play(AssetSource('sounds/score_100.wav'));
      } else if (score >= 70 && score <= 90) {
        await _resultPlayer.play(AssetSource('sounds/score_70_90.wav'));
      } else if (score >= 50 && score <= 60) {
        await _resultPlayer.play(AssetSource('sounds/score_50_60.wav'));
      } else {
        await _resultPlayer.play(AssetSource('sounds/score_0_40.wav'));
      }
    } catch (_) {}
  }

  /// Hentikan audio yang sedang berjalan jika layar ditutup
  static Future<void> stopResultSound() async {
    try {
      await _resultPlayer.stop();
    } catch (_) {}
  }

  static void dispose() {
    _clickPlayer.dispose();
    _resultPlayer.dispose();
  }
}
