import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/packing_item.dart';
import '../../data/repositories/packing_repository.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/packing_item_card.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _repo = PackingRepository();
  List<PackingItem> _items = [];
  Map<String, dynamic> _stats = {};
  Map<String, int> _categoryCounts = {};
  bool _loading = true;
  String? _nearestTripDate;

  late final AnimationController _planeCtrl;
  late final Animation<double> _planeAnimV;
  late final Animation<double> _planeAnimR;

  static const _categories = [
    'Dokumen',
    'Pakaian',
    'Peralatan Mandi',
    'Elektronik',
    'Obat-obatan',
  ];

  @override
  void initState() {
    super.initState();

    _planeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _planeAnimV = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _planeCtrl, curve: Curves.easeInOutSine),
    );

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.getAll(orderBy: 'tanggal_perjalanan ASC');
      final stats = await _repo.getStats();

      final counts = <String, int>{};
      for (final cat in _categories) {
        counts[cat] = 0;
      }
      String? nearestDate;
      for (final item in items) {
        counts[item.kategori] = (counts[item.kategori] ?? 0) + 1;
        if (nearestDate == null ||
            item.tanggalPerjalanan.compareTo(nearestDate) < 0) {
          nearestDate = item.tanggalPerjalanan;
        }
      }

      if (mounted) {
        setState(() {
          _items = items;
          _stats = stats;
          _categoryCounts = counts;
          _nearestTripDate = nearestDate;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus(PackingItem item) async {
    await _repo.toggleStatus(item.id!, item.statusPacking);
    _loadData();
  }

  Future<void> _deleteItem(PackingItem item) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Hapus Barang',
      message: 'Yakin ingin menghapus ${item.namaBarang} dari daftar?',
      confirmLabel: 'Ya, Hapus',
    );
    if (confirmed && mounted) {
      await _repo.deleteItem(item.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil dihapus')),
        );
        _loadData();
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  int _daysUntilTrip(String? dateStr) {
    if (dateStr == null) return 0;
    try {
      final tripDate = DateTime.parse(dateStr);
      return tripDate.difference(DateTime.now()).inDays;
    } catch (_) {
      return 0;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy', 'id').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _planeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TravelPack')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/add').then((_) => _loadData()),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const LoadingWidget(message: 'Memuat data...')
          : LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(),
                          if (_nearestTripDate != null) ...[
                            const SizedBox(height: 16),
                            _buildTravelSummary(),
                          ],
                          const SizedBox(height: 16),
                          _buildProgressSection(),
                          const SizedBox(height: 20),
                          _buildStatsRow(),
                          const SizedBox(height: 20),
                          _buildCategorySection(),
                          const SizedBox(height: 20),
                          _buildRecentItemsSection(),
                          if (_items.isEmpty) _buildEmptyState(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting().toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Siap Berpetualang?',
                  style: AppTextStyles.largeHeading.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.15),
                      AppColors.accent.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _planeCtrl,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _planeAnimV.value),
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.5),
                  AppColors.accent.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelSummary() {
    final days = _daysUntilTrip(_nearestTripDate);
    final dateStr = _formatDate(_nearestTripDate);
    final isUrgent = days <= 1;
    final isPast = days < 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPast
                      ? AppColors.error.withValues(alpha: 0.1)
                      : isUrgent
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPast
                      ? Icons.event_busy_rounded
                      : Icons.calendar_month_rounded,
                  color: isPast
                      ? AppColors.error
                      : isUrgent
                          ? AppColors.warning
                          : AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERJALANAN TERDEKAT',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: AppTextStyles.bodyTextMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPast
                      ? AppColors.error.withValues(alpha: 0.1)
                      : isUrgent
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPast
                      ? 'Berangkat'
                      : days == 0
                          ? 'Hari Ini'
                          : 'H-$days',
                  style: AppTextStyles.smallButton.copyWith(
                    color: isPast
                        ? AppColors.error
                        : isUrgent
                            ? AppColors.warning
                            : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final total = _stats['total'] as int? ?? 0;
    final packed = _stats['packed'] as int? ?? 0;
    final percentage = _stats['percentage'] as double? ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PROGRES PACKING',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$packed dari $total barang siap',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProgressBar(percentage: percentage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          StatCard(
            icon: Icons.luggage_rounded,
            label: 'Total Barang',
            value: '${_stats['total'] ?? 0}',
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          StatCard(
            icon: Icons.check_circle_rounded,
            label: 'Sudah Packing',
            value: '${_stats['packed'] ?? 0}',
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          StatCard(
            icon: Icons.hourglass_empty_rounded,
            label: 'Belum Packing',
            value: '${_stats['unpacked'] ?? 0}',
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          StatCard(
            icon: Icons.pie_chart_rounded,
            label: 'Persentase',
            value: '${(_stats['percentage'] ?? 0).round()}%',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'KATEGORI',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _categories.map((cat) {
              final count = _categoryCounts[cat] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _CategoryChip(
                  label: cat,
                  count: count,
                  onTap: () {},
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentItemsSection() {
    final recentItems = _items.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BARANG TERBARU',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_items.length > 5)
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/packing-list'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...recentItems.map(
          (item) => Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete_rounded,
                  color: Colors.white, size: 28),
            ),
            confirmDismiss: (_) async {
              await _deleteItem(item);
              return false;
            },
            child: PackingItemCard(
              item: item,
              onTap: () => Navigator.pushNamed(context, '/detail',
                      arguments: item.id)
                  .then((_) => _loadData()),
              onToggle: () => _toggleStatus(item),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 280,
      child: EmptyState(
        actionLabel: 'Tambah Barang Pertama',
        onAction: () =>
            Navigator.pushNamed(context, '/add').then((_) => _loadData()),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForCategory(label),
                size: 16,
                color: _colorForCategory(label),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _colorForCategory(label).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.captionBold.copyWith(
                    color: _colorForCategory(label),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'Dokumen':
        return Icons.description_rounded;
      case 'Pakaian':
        return Icons.checkroom_rounded;
      case 'Peralatan Mandi':
        return Icons.shower_rounded;
      case 'Elektronik':
        return Icons.bolt_rounded;
      case 'Obat-obatan':
        return Icons.medication_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _colorForCategory(String cat) {
    switch (cat) {
      case 'Dokumen':
        return AppColors.categoryDokumen;
      case 'Pakaian':
        return AppColors.categoryPakaian;
      case 'Peralatan Mandi':
        return AppColors.categoryMandi;
      case 'Elektronik':
        return AppColors.categoryElektronik;
      case 'Obat-obatan':
        return AppColors.categoryObat;
      default:
        return AppColors.textHint;
    }
  }
}
