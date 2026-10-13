import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/culture_model.dart';
import '../services/storage_service.dart';

class CultureDetailScreen extends StatefulWidget {
  final CultureItem item;

  const CultureDetailScreen({super.key, required this.item});

  @override
  State<CultureDetailScreen> createState() => _CultureDetailScreenState();
}

class _CultureDetailScreenState extends State<CultureDetailScreen> {
  bool _isLearned = false;

  @override
  void initState() {
    super.initState();
    _markAndCheckLearned();
  }

  Future<void> _markAndCheckLearned() async {
    await StorageService.markCultureAsLearned(widget.item.id);
    if (mounted) {
      setState(() {
        _isLearned = true;
      });
    }
  }

  Future<void> _toggleLearned() async {
    await StorageService.toggleCultureLearned(widget.item.id);
    final status = await StorageService.isCultureLearned(widget.item.id);
    if (mounted) {
      setState(() {
        _isLearned = status;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLearned
                ? '✅ Ditandai sudah dipelajari!'
                : '⏳ Ditandai belum dipelajari.',
          ),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 260.0,
            pinned: true,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    tooltip: _isLearned ? 'Selesai dipelajari' : 'Tandai selesai',
                    icon: Icon(
                      _isLearned ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                      color: _isLearned ? AppColors.accent : Colors.white,
                      size: 22,
                    ),
                    onPressed: _toggleLearned,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 6),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'culture-img-${item.id}',
                    child: Image.asset(
                      item.img,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primary.withOpacity(0.2),
                        child: const Icon(Icons.image, size: 80, color: Colors.white),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row: Region Pill + Progres Belajar Status
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Region Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(isDark ? 0.25 : 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.place_rounded,
                              size: 16,
                              color: isDark ? AppColors.accent : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Wilayah: ${item.region}',
                              style: TextStyle(
                                color: isDark ? AppColors.accentLight : AppColors.primaryDark,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Belajar Pill
                      InkWell(
                        onTap: _toggleLearned,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isLearned
                                ? const Color(0xFF2E7D32).withOpacity(isDark ? 0.3 : 0.15)
                                : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isLearned ? const Color(0xFF2E7D32) : Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isLearned
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 15,
                                color: _isLearned
                                    ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
                                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isLearned ? 'Selesai Dipelajari' : 'Belum Selesai',
                                style: TextStyle(
                                  color: _isLearned
                                      ? (isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20))
                                      : (isDark ? Colors.grey[300] : Colors.grey[800]),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Section Title & Description
                  Text(
                    'Mengenal Daerah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.desc,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informasi Kekayaan Adat
                  Text(
                    'Kekayaan Budaya & Adat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Detail Cards
                  ...item.details.map((detail) => _buildDetailCard(detail, isDark)),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(CultureDetail detail, bool isDark) {
    IconData iconData = Icons.palette_rounded;
    Color iconColor = isDark ? AppColors.accent : AppColors.primary;

    if (detail.title.toLowerCase().contains('tari')) {
      iconData = Icons.accessibility_new_rounded;
      iconColor = const Color(0xFFFFA726);
    } else if (detail.title.toLowerCase().contains('rumah')) {
      iconData = Icons.home_rounded;
      iconColor = const Color(0xFF42A5F5);
    } else if (detail.title.toLowerCase().contains('bahasa')) {
      iconData = Icons.record_voice_over_rounded;
      iconColor = const Color(0xFF66BB6A);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(isDark ? 0.22 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
