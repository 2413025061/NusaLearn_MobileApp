import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/hero_model.dart';
import '../services/storage_service.dart';

class HeroDetailScreen extends StatefulWidget {
  final HeroItem item;

  const HeroDetailScreen({super.key, required this.item});

  @override
  State<HeroDetailScreen> createState() => _HeroDetailScreenState();
}

class _HeroDetailScreenState extends State<HeroDetailScreen> {
  bool _isLearned = false;

  @override
  void initState() {
    super.initState();
    _markAndCheckLearned();
  }

  Future<void> _markAndCheckLearned() async {
    await StorageService.markHeroAsLearned(widget.item.id);
    if (mounted) {
      setState(() {
        _isLearned = true;
      });
    }
  }

  Future<void> _toggleLearned() async {
    await StorageService.toggleHeroLearned(widget.item.id);
    final status = await StorageService.isHeroLearned(widget.item.id);
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
            expandedHeight: 280.0,
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
                    tag: 'hero-img-${item.id}',
                    child: Image.asset(
                      item.img,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primary.withOpacity(0.2),
                        child: const Icon(Icons.person, size: 80, color: Colors.white),
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
                  // Info & Status Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : Colors.black.withOpacity(0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.accent.withOpacity(0.18)
                                    : AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.military_tech_rounded,
                                color: isDark ? AppColors.accent : AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.region,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.info,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: isDark ? AppColors.borderDark : Colors.grey[200],
                        ),
                        const SizedBox(height: 10),
                        // Status Progres Belajar Pill
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
                                  _isLearned ? 'Selesai Dipelajari' : 'Belum Dipelajari (Ketuk untuk menandai)',
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
                  ),

                  const SizedBox(height: 20),

                  // Peran Penting / Perjuangan
                  Text(
                    'Peran Penting & Perjuangan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : Colors.black.withOpacity(0.04),
                      ),
                    ),
                    child: Text(
                      item.desc,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Fakta Menarik Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                AppColors.accent.withOpacity(0.18),
                                AppColors.accentLight.withOpacity(0.08),
                              ]
                            : [
                                AppColors.accent.withOpacity(0.2),
                                AppColors.accentLight.withOpacity(0.3),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fakta Menarik:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.accentLight : AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.fakta,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
