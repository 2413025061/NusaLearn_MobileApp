import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/app_data.dart';
import '../services/storage_service.dart';
import 'culture_detail_screen.dart';
import 'hero_detail_screen.dart';

class LearningProgressScreen extends StatefulWidget {
  const LearningProgressScreen({super.key});

  @override
  State<LearningProgressScreen> createState() => _LearningProgressScreenState();
}

class _LearningProgressScreenState extends State<LearningProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<String> _learnedCultures = {};
  Set<String> _learnedHeroes = {};
  bool _isLoading = true;

  String _cultureFilter = 'Semua'; // 'Semua', 'Selesai', 'Belum'
  String _heroFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProgress() async {
    final cultures = await StorageService.getLearnedCultures();
    final heroes = await StorageService.getLearnedHeroes();
    if (mounted) {
      setState(() {
        _learnedCultures = cultures;
        _learnedHeroes = heroes;
        _isLoading = false;
      });
    }
  }

  String _getLevelTitle(double percentage) {
    if (percentage >= 0.8) return 'Mahaguru Nusantara 👑';
    if (percentage >= 0.5) return 'Pendekar Wawasan 🥇';
    if (percentage >= 0.2) return 'Pengelana Nusantara 🥈';
    return 'Penjelajah Pemula 🥉';
  }

  String _getLevelMotivation(double percentage) {
    if (percentage >= 1.0) return 'Luar biasa! Seluruh materi budaya dan pahlawan telah kamu kuasai!';
    if (percentage >= 0.8) return 'Hebat sekali! Sedikit lagi seluruh materi terselesaikan!';
    if (percentage >= 0.5) return 'Lebih dari separuh materi telah kamu pelajari. Terus semangat!';
    if (percentage >= 0.2) return 'Awal yang hebat! Terus perluas wawasan kebangsaanmu!';
    return 'Mulailah membaca materi budaya dan pahlawan untuk menaikkan levelmu!';
  }

  Future<void> _confirmResetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 8),
            Text('Reset Progres?'),
          ],
        ),
        content: const Text(
          'Semua catatan materi budaya dan pahlawan yang sudah dibaca akan dikembalikan ke awal.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.resetLearningProgress();
      await _loadAllProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Progres belajar berhasil direset.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCultures = AppData.cultures.length;
    final totalHeroes = AppData.heroes.length;
    final totalMateri = totalCultures + totalHeroes;

    final learnedCulturesCount = _learnedCultures.length;
    final learnedHeroesCount = _learnedHeroes.length;
    final totalLearned = learnedCulturesCount + learnedHeroesCount;

    final overallPercentage = totalMateri > 0 ? (totalLearned / totalMateri) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progres Belajar Nusantara'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset Progres',
            icon: const Icon(Icons.restart_alt_rounded, color: AppColors.primary),
            onPressed: _confirmResetProgress,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Header Dashboard Ringkasan Progres
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Progress Circle
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 68,
                                  height: 68,
                                  child: CircularProgressIndicator(
                                    value: overallPercentage,
                                    strokeWidth: 7,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                                  ),
                                ),
                                Text(
                                  '${(overallPercentage * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Level & Detail Title
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getLevelTitle(overallPercentage),
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$totalLearned dari $totalMateri Materi Selesai',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getLevelMotivation(overallPercentage),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11.5,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 2 Mini Progress Cards
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '🎭 Budaya Daerah',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$learnedCulturesCount / $totalCultures Provinsi',
                                      style: const TextStyle(color: AppColors.accentLight, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '🦸‍♂️ Pahlawan Nasional',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$learnedHeroesCount / $totalHeroes Tokoh',
                                      style: const TextStyle(color: AppColors.accentLight, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'Budaya ($learnedCulturesCount/$totalCultures)'),
                      Tab(text: 'Pahlawan ($learnedHeroesCount/$totalHeroes)'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCulturesTab(),
                      _buildHeroesTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCulturesTab() {
    final filtered = AppData.cultures.where((item) {
      if (_cultureFilter == 'Selesai') return _learnedCultures.contains(item.id);
      if (_cultureFilter == 'Belum') return !_learnedCultures.contains(item.id);
      return true;
    }).toList();

    return Column(
      children: [
        // Filter row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _buildFilterPill('Semua', 'Semua (${AppData.cultures.length})', _cultureFilter, (f) {
                setState(() => _cultureFilter = f);
              }),
              const SizedBox(width: 8),
              _buildFilterPill('Selesai', 'Selesai (${_learnedCultures.length})', _cultureFilter, (f) {
                setState(() => _cultureFilter = f);
              }),
              const SizedBox(width: 8),
              _buildFilterPill('Belum', 'Belum (${AppData.cultures.length - _learnedCultures.length})', _cultureFilter, (f) {
                setState(() => _cultureFilter = f);
              }),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada data pada filter ini',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isLearned = _learnedCultures.contains(item.id);
                    return _buildProgressItemCard(
                      title: item.title,
                      subtitle: 'Wilayah: ${item.region}',
                      imagePath: item.img,
                      isLearned: isLearned,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CultureDetailScreen(item: item)),
                        );
                        _loadAllProgress();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeroesTab() {
    final filtered = AppData.heroes.where((item) {
      if (_heroFilter == 'Selesai') return _learnedHeroes.contains(item.id);
      if (_heroFilter == 'Belum') return !_learnedHeroes.contains(item.id);
      return true;
    }).toList();

    return Column(
      children: [
        // Filter row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _buildFilterPill('Semua', 'Semua (${AppData.heroes.length})', _heroFilter, (f) {
                setState(() => _heroFilter = f);
              }),
              const SizedBox(width: 8),
              _buildFilterPill('Selesai', 'Selesai (${_learnedHeroes.length})', _heroFilter, (f) {
                setState(() => _heroFilter = f);
              }),
              const SizedBox(width: 8),
              _buildFilterPill('Belum', 'Belum (${AppData.heroes.length - _learnedHeroes.length})', _heroFilter, (f) {
                setState(() => _heroFilter = f);
              }),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada data pada filter ini',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isLearned = _learnedHeroes.contains(item.id);
                    return _buildProgressItemCard(
                      title: item.title,
                      subtitle: item.region,
                      imagePath: item.img,
                      isLearned: isLearned,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HeroDetailScreen(item: item)),
                        );
                        _loadAllProgress();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterPill(String key, String label, String currentKey, Function(String) onSelect) {
    final isSelected = key == currentKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withOpacity(0.25) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.accent : Colors.black.withOpacity(0.08),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItemCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required bool isLearned,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLearned ? const Color(0xFF2E7D32).withOpacity(0.3) : Colors.black.withOpacity(0.05),
          width: isLearned ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.image, color: AppColors.primary),
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isLearned
                ? const Color(0xFF2E7D32).withOpacity(0.12)
                : Colors.orange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLearned ? const Color(0xFF2E7D32) : Colors.orange,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLearned ? Icons.check_circle_rounded : Icons.pending_rounded,
                size: 13,
                color: isLearned ? const Color(0xFF2E7D32) : Colors.orange[800],
              ),
              const SizedBox(width: 4),
              Text(
                isLearned ? 'Selesai' : 'Belum',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isLearned ? const Color(0xFF1B5E20) : Colors.orange[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
