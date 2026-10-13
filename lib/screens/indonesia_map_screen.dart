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

class _IndonesiaMapScreenState extends State<IndonesiaMapScreen> with TickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late AnimationController _pulseController;
  Animation<Matrix4>? _mapAnimation;
  AnimationController? _animController;
  
  String _selectedRegion = 'Semua';
  CultureItem? _selectedCulture;
  Set<String> _learnedIds = {};
  Size _viewportSize = Size.zero;
  bool _hasInitialFitted = false;

  // Dimensi Kanvas Peta Indonesia (1400 x 700, rasio 2:1 — proporsional untuk layar mobile)
  static const double mapWidth = 1400.0;
  static const double mapHeight = 700.0;

  // 38 Titik Koordinat Presisi Geografis Provinsi Indonesia
  // Dikalibrasi ulang berdasarkan citra peta 1400 x 700 piksel
  static const List<ProvinceGeoPoint> _provincePoints = [
    // Sumatera
    ProvinceGeoPoint(id: 'aceh', name: 'Aceh', region: 'Sumatera', x: 121, y: 157),
    ProvinceGeoPoint(id: 'sumut', name: 'Sumatera Utara', region: 'Sumatera', x: 176, y: 208),
    ProvinceGeoPoint(id: 'sumbar', name: 'Sumatera Barat', region: 'Sumatera', x: 224, y: 287),
    ProvinceGeoPoint(id: 'riau', name: 'Riau', region: 'Sumatera', x: 264, y: 263),
    ProvinceGeoPoint(id: 'kepri', name: 'Kep. Riau', region: 'Sumatera', x: 334, y: 254),
    ProvinceGeoPoint(id: 'jambi', name: 'Jambi', region: 'Sumatera', x: 272, y: 326),
    ProvinceGeoPoint(id: 'bengkulu', name: 'Bengkulu', region: 'Sumatera', x: 275, y: 368),
    ProvinceGeoPoint(id: 'sumsel', name: 'Sumatera Selatan', region: 'Sumatera', x: 319, y: 376),
    ProvinceGeoPoint(id: 'babel', name: 'Bangka Belitung', region: 'Sumatera', x: 360, y: 362),
    ProvinceGeoPoint(id: 'lampung', name: 'Lampung', region: 'Sumatera', x: 350, y: 428),

    // Jawa
    ProvinceGeoPoint(id: 'banten', name: 'Banten', region: 'Jawa', x: 418, y: 484),
    ProvinceGeoPoint(id: 'jakarta', name: 'DKI Jakarta', region: 'Jawa', x: 446, y: 479),
    ProvinceGeoPoint(id: 'jabar', name: 'Jawa Barat', region: 'Jawa', x: 493, y: 497),
    ProvinceGeoPoint(id: 'jateng', name: 'Jawa Tengah', region: 'Jawa', x: 525, y: 476),
    ProvinceGeoPoint(id: 'jogja', name: 'D.I. Yogyakarta', region: 'Jawa', x: 527, y: 495),
    ProvinceGeoPoint(id: 'jatim', name: 'Jawa Timur', region: 'Jawa', x: 597, y: 507),

    // Kalimantan
    ProvinceGeoPoint(id: 'kalbar', name: 'Kalimantan Barat', region: 'Kalimantan', x: 514, y: 309),
    ProvinceGeoPoint(id: 'kalteng', name: 'Kalimantan Tengah', region: 'Kalimantan', x: 574, y: 335),
    ProvinceGeoPoint(id: 'kalsel', name: 'Kalimantan Selatan', region: 'Kalimantan', x: 618, y: 367),
    ProvinceGeoPoint(id: 'kaltim', name: 'Kalimantan Timur', region: 'Kalimantan', x: 631, y: 287),
    ProvinceGeoPoint(id: 'kaltara', name: 'Kalimantan Utara', region: 'Kalimantan', x: 641, y: 225),

    // Sulawesi
    ProvinceGeoPoint(id: 'sulut', name: 'Sulawesi Utara', region: 'Sulawesi', x: 890, y: 241),
    ProvinceGeoPoint(id: 'gorontalo', name: 'Gorontalo', region: 'Sulawesi', x: 829, y: 263),
    ProvinceGeoPoint(id: 'sulteng', name: 'Sulawesi Tengah', region: 'Sulawesi', x: 794, y: 312),
    ProvinceGeoPoint(id: 'sulbar', name: 'Sulawesi Barat', region: 'Sulawesi', x: 762, y: 340),
    ProvinceGeoPoint(id: 'sulsel', name: 'Sulawesi Selatan', region: 'Sulawesi', x: 765, y: 390),
    ProvinceGeoPoint(id: 'sultra', name: 'Sulawesi Tenggara', region: 'Sulawesi', x: 821, y: 399),

    // Bali & Nusa Tenggara
    ProvinceGeoPoint(id: 'bali', name: 'Bali', region: 'Bali & Nusa Tenggara', x: 673, y: 519),
    ProvinceGeoPoint(id: 'ntb', name: 'NTB', region: 'Bali & Nusa Tenggara', x: 715, y: 514),
    ProvinceGeoPoint(id: 'ntt', name: 'NTT', region: 'Bali & Nusa Tenggara', x: 802, y: 519),

    // Maluku & Papua
    ProvinceGeoPoint(id: 'malut', name: 'Maluku Utara', region: 'Maluku & Papua', x: 966, y: 266),
    ProvinceGeoPoint(id: 'maluku', name: 'Maluku', region: 'Maluku & Papua', x: 994, y: 368),
    ProvinceGeoPoint(id: 'papuabaratdaya', name: 'Papua Barat Daya', region: 'Maluku & Papua', x: 1067, y: 307),
    ProvinceGeoPoint(id: 'papuabarat', name: 'Papua Barat', region: 'Maluku & Papua', x: 1107, y: 330),
    ProvinceGeoPoint(id: 'papuatengah', name: 'Papua Tengah', region: 'Maluku & Papua', x: 1150, y: 371),
    ProvinceGeoPoint(id: 'papuapegunungan', name: 'Papua Pegunungan', region: 'Maluku & Papua', x: 1210, y: 377),
    ProvinceGeoPoint(id: 'papua', name: 'Papua', region: 'Maluku & Papua', x: 1231, y: 337),
    ProvinceGeoPoint(id: 'papuaselatan', name: 'Papua Selatan', region: 'Maluku & Papua', x: 1283, y: 452),
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
        if (_selectedCulture == null && AppData.cultures.isNotEmpty) {
          _selectedCulture = AppData.cultures.first;
        }
      });
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _pulseController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  /// Menghitung matriks pas layar penuh Indonesia
  Matrix4 _getFittedMatrix(Size viewport) {
    if (viewport.width <= 0 || viewport.height <= 0) {
      return Matrix4.identity();
    }
    // Skala agar seluruh lebar peta pas di viewport
    final double scaleX = viewport.width / mapWidth;
    final double scaleY = viewport.height / mapHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double scaledW = mapWidth * scale;
    final double scaledH = mapHeight * scale;

    // Pusatkan peta di viewport
    final double dx = (viewport.width - scaledW) / 2;
    final double dy = (viewport.height - scaledH) / 2;

    final matrix = Matrix4.identity();
    matrix.translate(dx, dy);
    matrix.scale(scale);
    return matrix;
  }

  /// Menghitung matriks fokus pulau
  Matrix4 _getRegionMatrix(String region, Size viewport) {
    if (region == 'Semua') {
      return _getFittedMatrix(viewport);
    }

    double targetX = 700;
    double targetY = 350;
    double zoomScale = 1.0;

    switch (region) {
      case 'Sumatera':
        targetX = 250;
        targetY = 295;
        zoomScale = 1.8;
        break;
      case 'Jawa':
        targetX = 520;
        targetY = 492;
        zoomScale = 2.4;
        break;
      case 'Kalimantan':
        targetX = 590;
        targetY = 305;
        zoomScale = 1.9;
        break;
      case 'Sulawesi':
        targetX = 810;
        targetY = 330;
        zoomScale = 2.0;
        break;
      case 'Bali & Nusa Tenggara':
        targetX = 750;
        targetY = 524;
        zoomScale = 2.4;
        break;
      case 'Maluku & Papua':
        targetX = 1120;
        targetY = 360;
        zoomScale = 1.7;
        break;
    }

    // Hitung skala dasar (fitted) lalu kalikan multiplier
    final double fitScale = (viewport.width / mapWidth) < (viewport.height / mapHeight)
        ? (viewport.width / mapWidth)
        : (viewport.height / mapHeight);
    final double finalScale = fitScale * zoomScale;

    final double tx = (viewport.width / 2) - (targetX * finalScale);
    final double ty = (viewport.height * 0.40) - (targetY * finalScale);

    final matrix = Matrix4.identity();
    matrix.translate(tx, ty);
    matrix.scale(finalScale);
    return matrix;
  }

  void _animateToMatrix(Matrix4 targetMatrix) {
    _animController?.dispose();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final startMatrix = _transformController.value;
    _mapAnimation = Matrix4Tween(begin: startMatrix, end: targetMatrix).animate(
      CurvedAnimation(parent: _animController!, curve: Curves.easeOutCubic),
    )..addListener(() {
        _transformController.value = _mapAnimation!.value;
      });

    _animController!.forward();
  }

  void _onRegionChanged(String region) {
    SoundService.playClick();
    setState(() {
      _selectedRegion = region;
    });

    if (_viewportSize != Size.zero) {
      final target = _getRegionMatrix(region, _viewportSize);
      _animateToMatrix(target);
    }

    // Otomatis pilih provinsi pertama di region tersebut
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
    });
    if (_viewportSize != Size.zero) {
      _animateToMatrix(_getFittedMatrix(_viewportSize));
    }
  }

  void _zoomIn() {
    SoundService.playClick();
    _zoomBy(1.4);
  }

  void _zoomOut() {
    SoundService.playClick();
    _zoomBy(0.7);
  }

  /// Zoom terpusat di layar: memperbesar/memperkecil dari titik tengah viewport
  void _zoomBy(double factor) {
    if (_viewportSize == Size.zero) return;

    final currentMatrix = _transformController.value.clone();
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale <= 0) return;

    // Batasi skala absolut
    final double targetScale = (currentScale * factor).clamp(0.08, 5.0);
    final double actualFactor = targetScale / currentScale;

    // Titik pusat zoom di tengah viewport
    final double cx = _viewportSize.width / 2;
    final double cy = _viewportSize.height / 2;

    final matrix = Matrix4.identity()
      ..translate(cx, cy)
      ..scale(actualFactor)
      ..translate(-cx, -cy)
      ..multiply(currentMatrix);

    _animateToMatrix(matrix);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCultures = AppData.cultures.length;
    final learnedCount = _learnedIds.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1722) : const Color(0xFFE3EDF7),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final curSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (!_hasInitialFitted && curSize.width > 0 && curSize.height > 0) {
            _viewportSize = curSize;
            _hasInitialFitted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _transformController.value = _getFittedMatrix(curSize);
              }
            });
          } else {
            _viewportSize = curSize;
          }

          return Stack(
            children: [
              // 1. PETA INTERAKTIF (InteractiveViewer + constrained:false + boundaryMargin:infinity)
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformController,
                  constrained: false,
                  // boundaryMargin infinite = cubit bebas perbesar & perkecil tanpa batas
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.08,
                  maxScale: 5.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  clipBehavior: Clip.none,
                  child: SizedBox(
                    width: mapWidth,
                    height: mapHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background Siluet Peta Asli Indonesia
                        Positioned.fill(
                          child: Image.asset(
                            isDark
                                ? 'assets/indonesia_map_dark.png'
                                : 'assets/indonesia_map_light.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),

                        // Watermark Nama Pulau Utama
                        ..._buildWatermarkLabels(isDark),

                        // 38 Pin Interaktif Provinsi Presisi (Titik pusat pin tepat di x, y)
                        ..._provincePoints.map((point) {
                          final isSelected = _selectedCulture?.id == point.id;
                          final isLearned = _learnedIds.contains(point.id);
                          final matchesRegion = _selectedRegion == 'Semua' || point.region == _selectedRegion;

                          return Positioned(
                            // Titik pusat koordinat tepat di point.x dan point.y
                            left: point.x - 20,
                            top: point.y - 20,
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              behavior: HitTestBehavior.deferToChild,
                              onTap: () => _selectProvinceById(point.id),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: matchesRegion ? 1.0 : 0.35,
                                child: Center(
                                  child: AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      final pulseScale = isSelected ? (1.0 + 0.20 * _pulseController.value) : 1.0;
                                      final double pinSize = isSelected ? 30.0 : 22.0;

                                      return Transform.scale(
                                        scale: pulseScale,
                                        child: Container(
                                          width: pinSize,
                                          height: pinSize,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (isDark ? AppColors.accent : AppColors.primary)
                                                : (isLearned
                                                    ? const Color(0xFF2E7D32)
                                                    : (isDark ? const Color(0xFF1E293B) : Colors.white)),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark ? Colors.white70 : AppColors.primary),
                                              width: isSelected ? 2.5 : 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isSelected
                                                    ? (isDark ? AppColors.accent.withOpacity(0.8) : AppColors.primary.withOpacity(0.6))
                                                    : Colors.black26,
                                                blurRadius: isSelected ? 12 : 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: isLearned && !isSelected
                                                ? const Icon(Icons.check, size: 13, color: Colors.white)
                                                : Icon(
                                                    Icons.place_rounded,
                                                    size: isSelected ? 18 : 13,
                                                    color: isSelected
                                                        ? (isDark ? Colors.black87 : Colors.white)
                                                        : (isDark ? Colors.white70 : AppColors.primary),
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // Label nama provinsi yang sedang terpilih (Callout melayang tepat di atas pin)
                        if (_selectedCulture != null) ...[
                          (() {
                            final selPoint = _provincePoints.firstWhere(
                              (p) => p.id == _selectedCulture!.id,
                              orElse: () => _provincePoints.first,
                            );
                            return Positioned(
                              left: selPoint.x - 70,
                              top: selPoint.y - 40,
                              width: 140,
                              child: IgnorePointer(
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.accent : AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black38,
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      selPoint.name,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.black87 : Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Toolbar Pemilihan Pulau / Wilayah (Atas)
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
                                  : (isDark ? AppColors.surfaceDark.withOpacity(0.92) : Colors.white.withOpacity(0.95)),
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

              // 3. Tombol Kontrol Zoom Mengambang (Kanan Atas)
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
                      icon: Icons.fit_screen_rounded,
                      tooltip: 'Tampilan Penuh Indonesia',
                      isDark: isDark,
                      onTap: _resetZoom,
                    ),
                  ],
                ),
              ),

              // 4. Panduan Geser & Cubit (Kiri Atas)
              Positioned(
                top: 64,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black87 : Colors.white).withOpacity(0.88),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : Colors.black12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pinch_rounded, size: 15, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Cubit layar untuk perbesar / perkecil',
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

              // 5. Kartu Detail Kebudayaan Provinsi Terpilih (Bawah)
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
          );
        },
      ),
    );
  }

  List<Widget> _buildWatermarkLabels(bool isDark) {
    Widget makeLabel(String title, double x, double y) {
      return Positioned(
        left: x,
        top: y,
        child: IgnorePointer(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
              color: (isDark ? Colors.white : Colors.black87).withOpacity(0.35),
            ),
          ),
        ),
      );
    }

    // Posisi watermark disesuaikan dengan kanvas 1400 x 700
    return [
      makeLabel('SUMATERA', 200, 334),
      makeLabel('JAWA', 500, 520),
      makeLabel('KALIMANTAN', 550, 270),
      makeLabel('SULAWESI', 800, 200),
      makeLabel('BALI & NUSA TENGGARA', 710, 550),
      makeLabel('MALUKU', 950, 385),
      makeLabel('PAPUA', 1160, 290),
    ];
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
              color: isDark ? AppColors.surfaceDark.withOpacity(0.92) : Colors.white.withOpacity(0.95),
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
              // Nama & Info Provinsi
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
                        'Wilayah: ${culture.region}',
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
          // Tombol Jelajahi Kebudayaan
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
