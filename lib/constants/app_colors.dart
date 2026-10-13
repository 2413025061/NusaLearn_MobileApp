import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama Tema Nusantara
  static const Color primary = Color(0xFF900500); // Merah Marun Khas NusaLearn
  static const Color primaryDark = Color(0xFF6B0300);
  static const Color primaryLight = Color(0xFFB82823);
  static const Color primaryDarkTheme = Color(0xFFE56762); // Merah Marun adaptif untuk Dark Mode
  static const Color accent = Color(0xFFD4B356); // Emas Budaya
  static const Color accentLight = Color(0xFFF0DE9B);
  
  // Background & Surface (Light Mode)
  static const Color background = Color(0xFFFFF5F0); // Krem Hangat
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF9F5F3);

  // Background & Surface (Dark Mode)
  static const Color backgroundDark = Color(0xFF161313); // Obsidian Hangat
  static const Color surfaceDark = Color(0xFF231E1E); // Permukaan Kartu Gelap
  static const Color surfaceDarkMuted = Color(0xFF2C2626); // Dialog / Muted
  static const Color borderDark = Color(0xFF383030); // Garis Tepi Gelap
  
  // Text Colors (Light Mode)
  static const Color textPrimary = Color(0xFF2B2323);
  static const Color textSecondary = Color(0xFF6A5C5C);
  static const Color textMuted = Color(0xFF9E8F8F);

  // Text Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFF5ECE9);
  static const Color textSecondaryDark = Color(0xFFC7B8B5);
  static const Color textMutedDark = Color(0xFF8F807D);
  
  // Feedback
  static const Color correct = Color(0xFF2E7D32); // Hijau Jawaban Benar
  static const Color wrong = Color(0xFFC62828); // Merah Jawaban Salah
  static const Color info = Color(0xFF1565C0);
}
