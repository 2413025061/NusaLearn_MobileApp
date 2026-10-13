import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/app_data.dart';
import '../models/culture_model.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import 'culture_detail_screen.dart';

class ProvinceGeoPoint {
  final String id;
  final String name;
  final String region;
  final double x;
  final double y;

  const ProvinceGeoPoint({
    required this.id,
    required this.name,
    required this.region,
    required this.x,
    required this.y,
  });
}

class IndonesiaMapScreen extends StatefulWidget {
  const IndonesiaMapScreen({super.key});

  @override
  State<IndonesiaMapScreen> createState() => _IndonesiaMapScreenState();
}

class _IndonesiaMapScreenState extends State<IndonesiaMapScreen> with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late AnimationController _pulseController;
  
  String _selectedRegion = 'Semua';
  CultureItem? _selectedCulture;
  Set<String> _learnedIds = {};

  // 38 Titik Koordinat Provinsi Indonesia (Skala Canvas 1050 x 560)
  static const List<ProvinceGeoPoint> _provincePoints = [
    // Sumatera
    ProvinceGeoPoint(id: 'aceh', name: 'Aceh', region: 'Sumatera', x: 95, y: 105),
    ProvinceGeoPoint(id: 'sumut', name: 'Sumatera Utara', region: 'Sumatera', x: 135, y: 155),
    ProvinceGeoPoint(id: 'sumbar', name: 'Sumatera Barat', region: 'Sumatera', x: 165, y: 235),
    ProvinceGeoPoint(id: 'riau', name: 'Riau', region: 'Sumatera', x: 205, y: 205),
    ProvinceGeoPoint(id: 'kepri', name: 'Kep. Riau', region: 'Sumatera', x: 260, y: 175),
    ProvinceGeoPoint(id: 'jambi', name: 'Jambi', region: 'Sumatera', x: 220, y: 260),
    ProvinceGeoPoint(id: 'bengkulu', name: 'Bengkulu', region: 'Sumatera', x: 195, y: 310),
    ProvinceGeoPoint(id: 'sumsel', name: 'Sumatera Selatan', region: 'Sumatera', x: 250, y: 310),
    ProvinceGeoPoint(id: 'babel', name: 'Bangka Belitung', region: 'Sumatera', x: 300, y: 275),
    ProvinceGeoPoint(id: 'lampung', name: 'Lampung', region: 'Sumatera', x: 270, y: 360),

    // Jawa
    ProvinceGeoPoint(id: 'banten', name: 'Banten', region: 'Jawa', x: 315, y: 415),
    ProvinceGeoPoint(id: 'jakarta', name: 'DKI Jakarta', region: 'Jawa', x: 345, y: 410),
    ProvinceGeoPoint(id: 'jabar', name: 'Jawa Barat', region: 'Jawa', x: 365, y: 430),
    ProvinceGeoPoint(id: 'jateng', name: 'Jawa Tengah', region: 'Jawa', x: 420, y: 435),
    ProvinceGeoPoint(id: 'jogja', name: 'D.I. Yogyakarta', region: 'Jawa', x: 425, y: 458),
    ProvinceGeoPoint(id: 'jatim', name: 'Jawa Timur', region: 'Jawa', x: 485, y: 440),

    // Kalimantan
    ProvinceGeoPoint(id: 'kalbar', name: 'Kalimantan Barat', region: 'Kalimantan', x: 385, y: 245),
    ProvinceGeoPoint(id: 'kalteng', name: 'Kalimantan Tengah', region: 'Kalimantan', x: 445, y: 265),
    ProvinceGeoPoint(id: 'kalsel', name: 'Kalimantan Selatan', region: 'Kalimantan', x: 495, y: 305),
    ProvinceGeoPoint(id: 'kaltim', name: 'Kalimantan Timur', region: 'Kalimantan', x: 505, y: 220),
    ProvinceGeoPoint(id: 'kaltara', name: 'Kalimantan Utara', region: 'Kalimantan', x: 510, y: 145),

    // Sulawesi
    ProvinceGeoPoint(id: 'sulut', name: 'Sulawesi Utara', region: 'Sulawesi', x: 675, y: 150),
    ProvinceGeoPoint(id: 'gorontalo', name: 'Gorontalo', region: 'Sulawesi', x: 640, y: 165),
    ProvinceGeoPoint(id: 'sulteng', name: 'Sulawesi Tengah', region: 'Sulawesi', x: 620, y: 225),
    ProvinceGeoPoint(id: 'sulbar', name: 'Sulawesi Barat', region: 'Sulawesi', x: 595, y: 265),
    ProvinceGeoPoint(id: 'sulsel', name: 'Sulawesi Selatan', region: 'Sulawesi', x: 605, y: 330),
    ProvinceGeoPoint(id: 'sultra', name: 'Sulawesi Tenggara', region: 'Sulawesi', x: 660, y: 315),

    // Bali & Nusa Tenggara
    ProvinceGeoPoint(id: 'bali', name: 'Bali', region: 'Bali & Nusa Tenggara', x: 545, y: 460),
    ProvinceGeoPoint(id: 'ntb', name: 'NTB', region: 'Bali & Nusa Tenggara', x: 595, y: 465),
    ProvinceGeoPoint(id: 'ntt', name: 'NTT', region: 'Bali & Nusa Tenggara', x: 675, y: 470),

    // Maluku & Papua
    ProvinceGeoPoint(id: 'malut', name: 'Maluku Utara', region: 'Maluku & Papua', x: 745, y: 195),
    ProvinceGeoPoint(id: 'maluku', name: 'Maluku', region: 'Maluku & Papua', x: 775, y: 295),
    ProvinceGeoPoint(id: 'papuabaratdaya', name: 'Papua Barat Daya', region: 'Maluku & Papua', x: 825, y: 225),
    ProvinceGeoPoint(id: 'papuabarat', name: 'Papua Barat', region: 'Maluku & Papua', x: 855, y: 260),
    ProvinceGeoPoint(id: 'papuatengah', name: 'Papua Tengah', region: 'Maluku & Papua', x: 895, y: 285),
    ProvinceGeoPoint(id: 'papuapegunungan', name: 'Papua Pegunungan', region: 'Maluku & Papua', x: 935, y: 290),
    ProvinceGeoPoint(id: 'papua', name: 'Papua', region: 'Maluku & Papua', x: 945, y: 240),
    ProvinceGeoPoint(id: 'papuaselatan', name: 'Papua Selatan', region: 'Maluku & Papua', x: 955, y: 350),
  ];

  static const List<String> _regions = [
    'Semua',
    'Sumatera',
    'Jawa',
    'Kalimantan',
    'Sulawesi',
    'Bali & Nusa Tenggara',
    'Maluku & Papua',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _loadLearnedData();
  }

  Future<void> _loadLearnedData() async {
    final learned = await StorageService.getLearnedCultures();
    if (mounted) {
      setState(() {
        _learnedIds = learned;
        // Default seleksi pertama ke Aceh jika belum ada
        if (_selectedCulture == null && AppData.cultures.isNotEmpty) {
          _selectedCulture = AppData.cultures.first;
        }
      });
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onRegionChanged(String region) {
    SoundService.playClick();
    setState(() {
      _selectedRegion = region;
    });

    // Auto zoom & pan fokus ke kepulauan yang dipilih
    final Matrix4 targetMatrix = Matrix4.identity();
    if (region == 'Sumatera') {
      targetMatrix.scale(1.8);
      targetMatrix.translate(-50.0, -100.0);
    } else if (region == 'Jawa') {
      targetMatrix.scale(2.2);
      targetMatrix.translate(-260.0, -320.0);
    } else if (region == 'Kalimantan') {
      targetMatrix.scale(1.9);
      targetMatrix.translate(-310.0, -110.0);
    } else if (region == 'Sulawesi') {
      targetMatrix.scale(2.0);
      targetMatrix.translate(-490.0, -160.0);
    } else if (region == 'Bali & Nusa Tenggara') {
      targetMatrix.scale(2.3);
      targetMatrix.translate(-490.0, -370.0);
    } else if (region == 'Maluku & Papua') {
      targetMatrix.scale(1.8);
      targetMatrix.translate(-670.0, -180.0);
    } else {
      // Reset zoom Semua
      targetMatrix.scale(1.0);
      targetMatrix.translate(0.0, 0.0);
    }

    _transformController.value = targetMatrix;

    // Pilih salah satu provinsi di region tersebut
    final firstInRegion = _provincePoints.firstWhere(
      (p) => region == 'Semua' || p.region == region,
      orElse: () => _provincePoints.first,
    );
    _selectProvinceById(firstInRegion.id);
  }

  void _selectProvinceById(String id) {
    SoundService.playClick();
    final found = AppData.cultures.firstWhere(
      (c) => c.id == id,
      orElse: () => AppData.cultures.first,
    );
    setState(() {
      _selectedCulture = found;
    });
  }

  void _resetZoom() {
    SoundService.playClick();
    setState(() {
      _selectedRegion = 'Semua';
      _transformController.value = Matrix4.identity();
    });
  }

  void _zoomIn() {
    SoundService.playClick();
    final matrix = _transformController.value.clone();
    matrix.scale(1.3, 1.3);
    _transformController.value = matrix;
  }

  void _zoomOut() {
    SoundService.playClick();
    final matrix = _transformController.value.clone();
    matrix.scale(0.77, 0.77);
    _transformController.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCultures = AppData.cultures.length;
    final learnedCount = _learnedIds.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10141D) : const Color(0xFFEBF3FC),
      appBar: AppBar(
        title: const Text('Peta Budaya Digital'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Indikator Progres Belajar di AppBar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDarkMuted : Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$learnedCount / $totalCultures Dibaca',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Interactive Map Canvas (Pan, Pinch & Zoom)
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.8,
              maxScale: 4.5,
              boundaryMargin: const EdgeInsets.all(180),
              child: Center(
                child: SizedBox(
                  width: 1050,
                  height: 560,
                  child: Stack(
                    children: [
                      // Vector Landmass & Oceans Canvas
                      Positioned.fill(
                        child: CustomPaint(
                          painter: IndonesiaMapPainter(
                            isDark: isDark,
                            selectedRegion: _selectedRegion,
                          ),
                        ),
                      ),

                      // Interactive Province Pins
                      ..._provincePoints.map((point) {
                        final isSelected = _selectedCulture?.id == point.id;
                        final isLearned = _learnedIds.contains(point.id);
                        final matchesRegion = _selectedRegion == 'Semua' || point.region == _selectedRegion;

                        return Positioned(
                          left: point.x - 22,
                          top: point.y - 28,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _selectProvinceById(point.id),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: matchesRegion ? 1.0 : 0.35,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  final pulseScale = isSelected ? (1.0 + 0.15 * _pulseController.value) : 1.0;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale: pulseScale,
                                        child: Container(
                                          width: isSelected ? 38 : 30,
                                          height: isSelected ? 38 : 30,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (isDark ? AppColors.accent : AppColors.primary)
                                                : (isLearned
                                                    ? const Color(0xFF2E7D32)
                                                    : (isDark ? const Color(0xFF263238) : Colors.white)),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark ? Colors.white38 : AppColors.primary),
                                              width: isSelected ? 2.5 : 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isSelected
                                                    ? (isDark ? AppColors.accent.withOpacity(0.6) : AppColors.primary.withOpacity(0.5))
                                                    : Colors.black26,
                                                blurRadius: isSelected ? 12 : 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: isLearned && !isSelected
                                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                                : Icon(
                                                    Icons.place_rounded,
                                                    size: isSelected ? 22 : 17,
                                                    color: isSelected
                                                        ? (isDark ? Colors.black87 : Colors.white)
                                                        : (isDark ? Colors.white70 : AppColors.primary),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      // Label Nama Provinsi Ringkas
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (isDark ? AppColors.accent : AppColors.primary)
                                              : (isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.85)),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSelected ? Colors.white38 : Colors.black12,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          point.name,
                                          style: TextStyle(
                                            fontSize: isSelected ? 10 : 8.5,
                                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                            color: isSelected
                                                ? (isDark ? Colors.black87 : Colors.white)
                                                : (isDark ? Colors.white : Colors.black87),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Bar Pemilihan Pulau / Region (Atas)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _regions.length,
                separatorBuilder: (context, i) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final reg = _regions[idx];
                  final isSelected = _selectedRegion == reg;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onRegionChanged(reg),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppColors.accent : AppColors.primary)
                              : (isDark ? AppColors.surfaceDark.withOpacity(0.9) : Colors.white.withOpacity(0.95)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppColors.accent : AppColors.primary)
                                : (isDark ? AppColors.borderDark : Colors.black.withOpacity(0.08)),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black45 : Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            reg,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? Colors.black87 : Colors.white)
                                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Tombol Floating Zoom Controls (Kanan Atas)
          Positioned(
            top: 64,
            right: 16,
            child: Column(
              children: [
                _buildMapControlBtn(
                  icon: Icons.add_rounded,
                  tooltip: 'Perbesar Peta',
                  isDark: isDark,
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.remove_rounded,
                  tooltip: 'Perkecil Peta',
                  isDark: isDark,
                  onTap: _zoomOut,
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.restart_alt_rounded,
                  tooltip: 'Reset Tampilan Peta',
                  isDark: isDark,
                  onTap: _resetZoom,
                ),
              ],
            ),
          ),

          // 4. Petunjuk Interaktif Singkat (Kiri Atas)
          Positioned(
            top: 64,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black87 : Colors.white).withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : Colors.black12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Geser & Cubit untuk Zoom Peta',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Kartu Detail Kebudayaan Provinsi yang Dipilih (Bawah)
          if (_selectedCulture != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: _buildCulturePreviewCard(
                culture: _selectedCulture!,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapControlBtn({
    required IconData icon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark.withOpacity(0.9) : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : Colors.black.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black45 : Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.accent : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCulturePreviewCard({
    required CultureItem culture,
    required bool isDark,
  }) {
    final isLearned = _learnedIds.contains(culture.id);

    // Ambil info ringkas rumah adat dan tari
    String rumahAdat = '-';
    String tariTradisional = '-';
    for (final d in culture.details) {
      if (d.title.toLowerCase().contains('rumah')) {
        rumahAdat = d.content;
      } else if (d.title.toLowerCase().contains('tari')) {
        tariTradisional = d.content;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.accent.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : AppColors.primary.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar thumbnail provinsi
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  culture.img,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                  errorBuilder: (context, err, stack) => Container(
                    width: 82,
                    height: 82,
                    color: isDark ? AppColors.surfaceDarkMuted : Colors.grey[200],
                    child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nama & Badge Region
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            culture.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Badge status sudah dibaca
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isLearned
                                ? const Color(0xFF2E7D32).withOpacity(0.15)
                                : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isLearned ? const Color(0xFF2E7D32) : Colors.grey,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLearned ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                size: 12,
                                color: isLearned ? const Color(0xFF2E7D32) : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isLearned ? 'Selesai' : 'Belum',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isLearned ? const Color(0xFF2E7D32) : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Region Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDarkMuted : AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Pulau: ${culture.region}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Snippet Rumah Adat
                    Row(
                      children: [
                        const Text('🏠 ', style: TextStyle(fontSize: 11)),
                        Expanded(
                          child: Text(
                            rumahAdat,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Snippet Tari Tradisional
                    Row(
                      children: [
                        const Text('💃 ', style: TextStyle(fontSize: 11)),
                        Expanded(
                          child: Text(
                            tariTradisional,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tombol Buka Detail Kebudayaan Daerah
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                SoundService.playClick();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CultureDetailScreen(item: culture),
                  ),
                );
                _loadLearnedData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryDarkTheme : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.explore_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Lihat Kebudayaan ${culture.title}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter untuk menggambar siluet pulau-pulau besar kepulauan Indonesia
class IndonesiaMapPainter extends CustomPainter {
  final bool isDark;
  final String selectedRegion;

  IndonesiaMapPainter({
    required this.isDark,
    required this.selectedRegion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gambar Grid Maritim / Samudra
    _drawMaritimeGrid(canvas, size);

    // 2. Gambar Pulau-Pulau Utama Nusantara
    _drawIslands(canvas, size);

    // 3. Gambar Label Kepulauan
    _drawIslandLabels(canvas);
  }

  void _drawMaritimeGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white.withOpacity(0.04) : Colors.blueGrey.withOpacity(0.08))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Garis horizontal (lintang)
    for (double y = 50; y < size.height; y += 70) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    // Garis vertikal (bujur)
    for (double x = 70; x < size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Garis Khatulistiwa / Equator (y = 210)
    final equatorPaint = Paint()
      ..color = (isDark ? AppColors.accent.withOpacity(0.2) : Colors.red.withOpacity(0.18))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, 210), Offset(size.width, 210), equatorPaint);
  }

  void _drawIslands(Canvas canvas, Size size) {
    // Warna pulau normal vs highlight jika wilayah dipilih
    Color getLandColor(String region) {
      final isHighlighted = selectedRegion == 'Semua' || selectedRegion == region;
      if (isDark) {
        return isHighlighted ? const Color(0xFF1E4636) : const Color(0xFF1B2838);
      } else {
        return isHighlighted ? const Color(0xFFC8E6C9) : const Color(0xFFD7E5F0);
      }
    }

    Color getCoastColor(String region) {
      final isHighlighted = selectedRegion == 'Semua' || selectedRegion == region;
      if (isDark) {
        return isHighlighted ? const Color(0xFF4CAF50) : const Color(0xFF2C3E50);
      } else {
        return isHighlighted ? const Color(0xFF43A047) : const Color(0xFF90A4AE);
      }
    }

    void drawLandMass(Path path, String region) {
      final fillPaint = Paint()
        ..color = getLandColor(region)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = getCoastColor(region)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }

    // --- PULAU SUMATERA ---
    final sumatera = Path()
      ..moveTo(80, 80)
      ..lineTo(125, 115)
      ..lineTo(155, 160)
      ..lineTo(215, 230)
      ..lineTo(260, 310)
      ..lineTo(285, 365)
      ..lineTo(265, 380)
      ..lineTo(235, 360)
      ..lineTo(190, 305)
      ..lineTo(145, 230)
      ..lineTo(110, 160)
      ..lineTo(70, 110)
      ..close();
    drawLandMass(sumatera, 'Sumatera');

    // Pulau Bangka & Belitung
    final bangka = Path()
      ..addOval(Rect.fromCenter(center: const Offset(295, 260), width: 28, height: 42));
    drawLandMass(bangka, 'Sumatera');

    final belitung = Path()
      ..addOval(Rect.fromCenter(center: const Offset(330, 290), width: 22, height: 22));
    drawLandMass(belitung, 'Sumatera');

    // Pulau Nias & Mentawai
    final nias = Path()
      ..addOval(Rect.fromCenter(center: const Offset(95, 180), width: 14, height: 26));
    drawLandMass(nias, 'Sumatera');

    // --- PULAU JAWA ---
    final jawa = Path()
      ..moveTo(300, 410)
      ..lineTo(350, 405)
      ..lineTo(410, 420)
      ..lineTo(470, 425)
      ..lineTo(510, 440)
      ..lineTo(495, 455)
      ..lineTo(430, 450)
      ..lineTo(370, 445)
      ..lineTo(320, 435)
      ..close();
    drawLandMass(jawa, 'Jawa');

    // Pulau Madura
    final madura = Path()
      ..addOval(Rect.fromCenter(center: const Offset(490, 415), width: 34, height: 16));
    drawLandMass(madura, 'Jawa');

    // --- PULAU KALIMANTAN ---
    final kalimantan = Path()
      ..moveTo(370, 205)
      ..lineTo(425, 140)
      ..lineTo(485, 120)
      ..lineTo(525, 145)
      ..lineTo(530, 215)
      ..lineTo(515, 290)
      ..lineTo(475, 325)
      ..lineTo(435, 305)
      ..lineTo(365, 295)
      ..lineTo(350, 245)
      ..close();
    drawLandMass(kalimantan, 'Kalimantan');

    // --- PULAU SULAWESI (Bentuk K Ikonis) ---
    final sulawesi = Path()
      ..moveTo(630, 160)
      ..lineTo(685, 140) // lengan utara (Minahasa)
      ..lineTo(670, 165)
      ..lineTo(625, 190) // leher
      ..lineTo(665, 220) // lengan timur
      ..lineTo(645, 245)
      ..lineTo(620, 240) // pusat
      ..lineTo(670, 310) // lengan tenggara
      ..lineTo(640, 325)
      ..lineTo(610, 275) // teluk bone
      ..lineTo(615, 345) // lengan selatan (Makassar)
      ..lineTo(585, 340)
      ..lineTo(580, 260)
      ..lineTo(600, 195)
      ..close();
    drawLandMass(sulawesi, 'Sulawesi');

    // --- BALI & NUSA TENGGARA ---
    // Bali
    final bali = Path()
      ..addOval(Rect.fromCenter(center: const Offset(540, 460), width: 22, height: 18));
    drawLandMass(bali, 'Bali & Nusa Tenggara');

    // Lombok & Sumbawa
    final ntbPath = Path()
      ..addOval(Rect.fromCenter(center: const Offset(570, 465), width: 18, height: 18))
      ..addOval(Rect.fromCenter(center: const Offset(605, 465), width: 36, height: 20));
    drawLandMass(ntbPath, 'Bali & Nusa Tenggara');

    // Flores, Sumba & Timor (NTT)
    final nttPath = Path()
      ..addOval(Rect.fromCenter(center: const Offset(665, 465), width: 48, height: 16))
      ..addOval(Rect.fromCenter(center: const Offset(655, 490), width: 32, height: 18))
      ..addOval(Rect.fromCenter(center: const Offset(710, 480), width: 38, height: 20));
    drawLandMass(nttPath, 'Bali & Nusa Tenggara');

    // --- KEPULAUAN MALUKU ---
    // Halmahera & Morotai (Maluku Utara)
    final malut = Path()
      ..moveTo(745, 160)
      ..lineTo(765, 175)
      ..lineTo(755, 215)
      ..lineTo(735, 195)
      ..close();
    drawLandMass(malut, 'Maluku & Papua');

    // Seram, Buru, Ambon (Maluku)
    final maluku = Path()
      ..addOval(Rect.fromCenter(center: const Offset(740, 275), width: 26, height: 18)) // Buru
      ..addOval(Rect.fromCenter(center: const Offset(785, 280), width: 44, height: 20)); // Seram
    drawLandMass(maluku, 'Maluku & Papua');

    // --- PULAU PAPUA (Bentuk Kepala Burung Cenderawasih) ---
    final papua = Path()
      ..moveTo(815, 210) // Kepala Burung (Doberai)
      ..lineTo(845, 205)
      ..lineTo(840, 240)
      ..lineTo(865, 235) // Leher
      ..lineTo(915, 220) // Pantai Utara
      ..lineTo(965, 245)
      ..lineTo(975, 340) // Perbatasan Merauke
      ..lineTo(925, 335)
      ..lineTo(885, 290)
      ..lineTo(840, 275)
      ..lineTo(810, 245)
      ..close();
    drawLandMass(papua, 'Maluku & Papua');
  }

  void _drawIslandLabels(Canvas canvas) {
    void drawLabel(String text, Offset pos) {
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: (isDark ? Colors.white : Colors.black87).withOpacity(0.35),
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, pos);
    }

    drawLabel('SUMATERA', const Offset(135, 275));
    drawLabel('JAWA', const Offset(380, 465));
    drawLabel('KALIMANTAN', const Offset(395, 200));
    drawLabel('SULAWESI', const Offset(625, 120));
    drawLabel('NUSA TENGGARA', const Offset(590, 500));
    drawLabel('MALUKU', const Offset(735, 320));
    drawLabel('PAPUA', const Offset(885, 195));
  }

  @override
  bool shouldRepaint(covariant IndonesiaMapPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.selectedRegion != selectedRegion;
  }
}
