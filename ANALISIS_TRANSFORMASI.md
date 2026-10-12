# DOKUMEN ANALISIS TRANSFORMASI SISTEM
## "NusaLearn: Eksplorasi Budaya dan Pahlawan Indonesia"
**Dari Multimedia Pembelajaran Interaktif (Web Wrapper) ke Aplikasi Mobile Murni (Flutter)**

---

### Informasi Proyek & Pengembang
* **Nama Proyek:** NusaLearn Mobile
* **Pengembang:** Ibnaty Chalisa Adabina
* **NPM:** 2413025061
* **Kelas:** PTI24 A
* **Program Studi:** Pendidikan Teknologi Informasi
* **Institusi:** Fakultas Keguruan dan Ilmu Pendidikan, Universitas Lampung (2026)
* **Target Pengguna:** Siswa SD kelas 4–6 dan SMP

---

### 1. Latar Belakang & Identifikasi Masalah
Proyek NusaLearn sebelumnya dikembangkan sebagai media pembelajaran interaktif berbasis web (HTML5, CSS3, dan Vanilla JavaScript) yang kemudian dibungkus (*wrapper*) menjadi berkas APK menggunakan platform pihak ketiga (AppsGeyser). 

Meskipun konten dan konsep visualnya telah lengkap, solusi pembungkus web tersebut memiliki beberapa kelemahan fundamental:
1. **Performa & Animasi Terbatas:** Ketergantungan pada WebView menimbulkan *framerate drop* dan scrolling yang kurang responsif pada smartphone berspesifikasi menengah ke bawah.
2. **Navigasi Layar Kaku:** Berpindah antar-layar hanya mengandalkan pergantian *display class* di DOM tanpa dukungan *gesture navigation* native Android (seperti tombol *Back* fisik/gesture samping).
3. **Penyimpanan State Sederhana:** Skor kuis dan progres belajar langsung hilang begitu tab atau aplikasi ditutup.
4. **Kesesuaian Akademik:** Untuk memenuhi standar perkuliahan **Mobile Programming**, aplikasi perlu dibangun menggunakan bahasa dan *framework* mobile terstruktur (Flutter + Dart) dengan arsitektur berlapis yang mudah dipelihara.

---

### 2. Inventarisasi Aset & Data Konten
Seluruh aset visual dan materi dari proyek web sebelumnya berhasil dimigrasikan 100% tanpa kehilangan konten:
* **38 Budaya Daerah (38 Provinsi di Indonesia):** 
  * Meliputi Aceh hingga Papua Barat Daya, Papua Tengah, Papua Pegunungan, dan Papua Selatan.
  * Dilengkapi informasi: Sejarah ringkas, Tari Tradisional, Rumah Adat, dan Bahasa Daerah.
* **38 Tokoh Pahlawan Nasional Indonesia:**
  * Profil pejuang dari Sabang sampai Merauke.
  * Dilengkapi informasi: Daerah asal, biografi perjuangan, dan sorotan **Fakta Menarik**.
* **Bank Soal Kuis (30 Soal):**
  * Terdiri dari 15 soal kebudayaan dan 15 soal pahlawan, lengkap dengan 4 opsi pilihan ganda, kunci jawaban, dan pembahasan edukatif.
* **78 Berkas Gambar Lokal di `assets/`:**
  * Dipetakan langsung ke dalam `pubspec.yaml` untuk pemuatan *offline ready*.

---

### 3. Matriks Perbandingan & Peningkatan Fitur (Web vs Flutter Mobile)

| Komponen / Fitur | Versi Web Lama | Versi Flutter Mobile Murni (Baru) |
| :--- | :--- | :--- |
| **Teknologi Inti** | HTML5, CSS3, JS (Web Wrapper) | **Flutter 3.47+ & Dart 3.13+ (100% Native Android)** |
| **Transisi Gambar** | Berganti kaku saat diklik | **Hero Animation Widget** (gambar kartu meluncur dan membesar secara dramatis) |
| **Navigasi Antarmuka** | Manipulasi kelas CSS | **Navigator Stack & CustomScrollView** (mendukung gesture swipe & tombol back native) |
| **Pencarian & Eksplorasi**| Input teks biasa | **Realtime Search Bar + Filter Chips Pulau** (Sumatera, Jawa, Kalimantan, Sulawesi, Bali-Nusa, Maluku-Papua) |
| **Sistem Evaluasi Kuis** | Variabel JS global | **Modular Quiz Engine** dengan pengacakan 10 dari 30 soal, timer hitung mundur 15 detik, dan modal feedback |
| **Penyimpanan Skor** | Tidak ada (hilang saat ditutup) | **High Score Lokal (Rekor Terbaik)** tersimpan di memori perangkat via `shared_preferences` |
| **Efek Gamifikasi** | Canvas-confetti JS | **Native Flutter Confetti Widget** saat pengguna meraih skor tinggi |
| **Tipografi & Desain** | Segoe UI sistem | **Google Fonts (Poppins)** dengan palet Nusantara Modern: Merah Marun (`#900500`), Emas (`#D4B356`), dan Krem (`#FFF5F0`) |

---

### 4. Struktur Arsitektur Perangkat Lunak (Clean Layered Architecture)

Proyek telah diatur dengan struktur direktori yang modular dan teratur:

```text
lib/
├── constants/
│   ├── app_colors.dart         # Palet warna identitas NusaLearn
│   └── app_theme.dart          # Tema Material 3, tipografi Poppins, card & button styling
├── data/
│   └── app_data.dart           # Bank data 38 budaya, 38 pahlawan, & 30 soal kuis
├── models/
│   ├── culture_model.dart      # Entitas CultureItem & CultureDetail
│   ├── hero_model.dart         # Entitas HeroItem
│   └── quiz_model.dart         # Entitas QuizQuestion & QuizResult
├── screens/
│   ├── splash_screen.dart      # Layar pembuka animasi logo + tombol Mulai
│   ├── home_screen.dart        # Beranda dengan statistik High Score & 4 menu utama
│   ├── culture_list_screen.dart# Daftar 38 budaya + pencarian + filter pulau
│   ├── culture_detail_screen.dart # Detail tarian, rumah adat, & bahasa dengan Hero sliver
│   ├── hero_list_screen.dart   # Daftar 38 pahlawan + pencarian + filter pulau
│   ├── hero_detail_screen.dart # Detail biografi perjuangan & kartu fakta menarik
│   ├── quiz_intro_screen.dart  # Pengantar aturan kuis & rekapan rekor
│   ├── quiz_play_screen.dart   # Sesi kuis interaktif (Timer 15s + Modal Feedback)
│   ├── quiz_result_screen.dart # Evaluasi skor + hujan partikel konfeti
│   └── about_screen.dart       # Profil pengembang PTI Unila 2026
├── services/
│   └── storage_service.dart    # Manajemen penyimpanan skor via SharedPreferences
└── main.dart                   # Entry point aplikasi & konfigurasi System UI
```

---

### 5. Hasil Pengujian & Validasi Kualitas Kode
1. **Analisis Statis (`flutter analyze`):**
   * Status: **No issues found!** (Bebas dari kesalahan sintaks, tipe data, maupun peringatan fatal).
2. **Pengujian Widget Unit (`flutter test`):**
   * Status: **All tests passed!** (Aplikasi berhasil dirender tanpa crash).
3. **Pembersihan Berkas:**
   * Berkas web lama yang tidak lagi diperlukan (`index.html`, `style.css`, `script.js`) telah dibersihkan sehingga repositori kini berstatus sebagai proyek Flutter native murni.

---

*Dokumen ini disusun sebagai acuan teknis dan laporan penyelarasan proyek perkuliahan Mobile Programming.*
