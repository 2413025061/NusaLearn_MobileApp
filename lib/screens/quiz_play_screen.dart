import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/app_data.dart';
import '../models/quiz_model.dart';
import '../services/storage_service.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late List<QuizQuestion> _sessionQuestions;
  int _currentIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  int _timeLeft = 15;
  Timer? _timer;
  bool _isAnswerChecked = false;
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  void _initQuiz() {
    // Ambil 10 soal secara acak dari bank 30 soal
    final shuffled = List<QuizQuestion>.from(AppData.questions)..shuffle();
    _sessionQuestions = shuffled.take(10).toList();
    _currentIndex = 0;
    _score = 0;
    _correctCount = 0;
    _startTimerForQuestion();
  }

  void _startTimerForQuestion() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 15;
      _isAnswerChecked = false;
      _selectedOptionIndex = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 1) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _onAnswerSubmitted(-1); // Timeout
      }
    });
  }

  void _onAnswerSubmitted(int selectedIndex) {
    if (_isAnswerChecked) return;
    _timer?.cancel();

    final currentQ = _sessionQuestions[_currentIndex];
    final isCorrect = selectedIndex == currentQ.answerIndex;

    setState(() {
      _isAnswerChecked = true;
      _selectedOptionIndex = selectedIndex;
      if (isCorrect) {
        _score += 10;
        _correctCount++;
      }
    });

    _showFeedbackDialog(isCorrect: isCorrect, isTimeout: selectedIndex == -1, question: currentQ);
  }

  void _showFeedbackDialog({
    required bool isCorrect,
    required bool isTimeout,
    required QuizQuestion question,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        String statusTitle;
        Color statusColor;
        IconData statusIcon;

        if (isTimeout) {
          statusTitle = 'WAKTU HABIS! ⏱️';
          statusColor = const Color(0xFFE65100);
          statusIcon = Icons.hourglass_disabled_rounded;
        } else if (isCorrect) {
          statusTitle = 'JAWABAN BENAR! 🎉';
          statusColor = AppColors.correct;
          statusIcon = Icons.check_circle_rounded;
        } else {
          statusTitle = 'JAWABAN SALAH ❌';
          statusColor = AppColors.wrong;
          statusIcon = Icons.cancel_rounded;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                statusTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  question.explanation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _goToNextQuestion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    _currentIndex < _sessionQuestions.length - 1
                        ? 'Lanjut Soal Berikutnya'
                        : 'Lihat Hasil Kuis',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToNextQuestion() async {
    if (_currentIndex < _sessionQuestions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startTimerForQuestion();
    } else {
      // Sesi Kuis Selesai! Simpan skor
      await StorageService.saveScore(_score);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              result: QuizResult(
                totalQuestions: _sessionQuestions.length,
                correctAnswers: _correctCount,
                score: _score,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _sessionQuestions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kuis NusaLearn'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar dari Kuis?'),
                  content: const Text('Progres kuis saat ini tidak akan disimpan jika kamu keluar.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Lanjutkan Kuis'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Tutup dialog
                        Navigator.pop(context); // Kembali ke Intro
                      },
                      child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Progres & Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Soal ${_currentIndex + 1} / ${_sessionQuestions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  // Timer Circle
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _timeLeft <= 5 ? AppColors.wrong : AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: (_timeLeft <= 5 ? AppColors.wrong : AppColors.primary).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_timeLeft',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _sessionQuestions.length,
                  backgroundColor: Colors.black.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 24),

              // Kartu Soal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  currentQ.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Pilihan Jawaban
              Expanded(
                child: ListView.builder(
                  itemCount: currentQ.options.length,
                  itemBuilder: (context, idx) {
                    final option = currentQ.options[idx];
                    final isSelected = _selectedOptionIndex == idx;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isAnswerChecked ? null : () => _onAnswerSubmitted(idx),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.08),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.background,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    String.fromCharCode(65 + idx), // A, B, C, D
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
