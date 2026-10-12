class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
  final String category; // 'budaya' or 'pahlawan'

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
    required this.category,
  });
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int score;

  const QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
  });

  String get feedbackTitle {
    if (score == 100) return 'LUAR BIASA! 🎆';
    if (score >= 70) return 'Bagus Sekali! 👏';
    return 'Ayo Semangat Belajar! 💪';
  }

  String get feedbackMessage {
    if (score == 100) {
      return 'Kamu berhasil menjawab semua pertanyaan dengan sempurna! Pengetahuanmu tentang Indonesia sungguh mengagumkan.';
    }
    if (score >= 70) {
      return 'Hasil yang sangat memuaskan! Pertahankan prestasimu dan terus cintai budaya bangsa.';
    }
    return 'Jangan berkecil hati, pelajari lagi materi budaya dan pahlawan lalu coba kuis ini kembali!';
  }
}
