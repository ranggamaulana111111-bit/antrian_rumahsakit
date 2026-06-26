import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/packing_item.dart';
import '../../data/repositories/packing_repository.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class PackingItemDetailPage extends StatefulWidget {
  final int itemId;

  const PackingItemDetailPage({super.key, required this.itemId});

  @override
  State<PackingItemDetailPage> createState() => _PackingItemDetailPageState();
}

class _PackingItemDetailPageState extends State<PackingItemDetailPage>
    with SingleTickerProviderStateMixin {
  final _repo = PackingRepository();
  PackingItem? _item;
  bool _loading = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _loadItem();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    setState(() => _loading = true);
    try {
      final item = await _repo.getById(widget.itemId);
      if (mounted) {
        setState(() {
          _item = item;
          _loading = false;
        });
        _animCtrl.forward(from: 0);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteItem() async {
    if (_item == null) return;
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Hapus Barang',
      message: 'Yakin ingin menghapus ${_item!.namaBarang}?',
      confirmLabel: 'Ya, Hapus',
    );
    if (confirmed && mounted) {
      await _repo.deleteItem(widget.itemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil dihapus')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_item?.namaBarang ?? 'Detail Barang')),
      body: _loading
          ? const LoadingWidget(message: 'Memuat...')
          : _item == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildInfoCard(),
                          if (_item!.catatan != null &&
                              _item!.catatan!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildCatatanCard(),
                          ],
                          const SizedBox(height: 32),
                          _buildActions(),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final isPacked = _item!.statusPacking == 1;
    final icon = isPacked
        ? Icons.check_circle_rounded
        : Icons.radio_button_unchecked_rounded;
    final statusText = isPacked ? 'Sudah Dipacking' : 'Belum Dipacking';
    final statusColor = isPacked ? AppColors.success : AppColors.warning;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 30,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: statusColor.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(icon, size: 34, color: statusColor),
          ),
          const SizedBox(height: 16),
          Text(
            _item!.namaBarang,
            style: AppTextStyles.largeHeading.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CategoryBadge(kategori: _item!.kategori),
              const SizedBox(width: 8),
              PriorityBadge(prioritas: _item!.prioritas),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPacked
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_empty_rounded,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style:
                      AppTextStyles.captionBold.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final date = _item!.tanggalPerjalanan;
    String formattedDate = date;
    try {
      final parsed = DateTime.parse(date);
      formattedDate = DateFormat('dd MMMM yyyy', 'id').format(parsed);
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _infoRow(
            Icons.calendar_month_rounded,
            'Tanggal Perjalanan',
            formattedDate,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _infoRow(Icons.category_rounded, 'Kategori', _item!.kategori),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _infoRow(Icons.flag_rounded, 'Prioritas', _item!.prioritas),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyTextMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCatatanCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notes_rounded,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Catatan',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _item!.catatan!,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/edit',
                    arguments: widget.itemId)
                .then((_) => _loadItem()),
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: _deleteItem,
            icon: const Icon(Icons.delete_rounded, size: 20),
            label: const Text('Hapus'),
          ),
        ),
      ],
    );
  }
}
