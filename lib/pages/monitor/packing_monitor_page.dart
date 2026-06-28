import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/packing_log.dart';
import '../../data/repositories/packing_repository.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

class PackingMonitorPage extends StatefulWidget {
  const PackingMonitorPage({super.key});

  @override
  State<PackingMonitorPage> createState() => _PackingMonitorPageState();
}

class _PackingMonitorPageState extends State<PackingMonitorPage> {
  final _repo = PackingRepository();
  List<PackingLog> _logs = [];
  Map<String, dynamic> _logStats = {};
  bool _loading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadLogs();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await _repo.getAllLogs();
      final stats = await _repo.getLogStats();
      if (mounted) {
        setState(() {
          _logs = logs;
          _logStats = stats;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('HH:mm:ss').format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _lastRunTime() {
    if (_logs.isEmpty) return '-';
    return _formatDate(_logs.first.createdAt);
  }

  Color _statusColor(String status) {
    if (status.contains('100%')) return AppColors.success;
    if (status.contains('Pending')) return AppColors.warning;
    return AppColors.accent;
  }

  IconData _statusIcon(String status) {
    if (status.contains('100%')) return Icons.check_circle_rounded;
    if (status.contains('QC')) return Icons.verified_rounded;
    if (status.contains('Pending')) return Icons.schedule_rounded;
    return Icons.inventory_2_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Packing Monitor')),
      drawer: const AppDrawer(),
      body: _loading
          ? const LoadingWidget(message: 'Memuat log aktivitas...')
          : Column(
              children: [
                _buildHeader(),
                _buildTable(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    final totalPacked = _logStats['packed'] ?? 0;
    final totalLogs = _logStats['total'] ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
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
                      Icons.monitor_heart_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Packing Monitor',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.access_time_rounded,
                'Last Run',
                _lastRunTime(),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.checklist_rounded,
                'Total Packed',
                '$totalPacked dari $totalLogs item',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    if (_logs.isEmpty) {
      return Expanded(
        child: Center(
          child: EmptyState(
            icon: Icons.monitor_heart_outlined,
            title: 'Belum ada aktivitas',
            message:
                'Aktivitas packing akan muncul di sini setelah Anda mencentang barang.',
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTableHeader(),
            Divider(height: 1, color: AppColors.divider),
            Expanded(child: _buildTableBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          _tableCell('Time', 70),
          _tableCell('Item/SKU', 1, flex: true),
          const SizedBox(width: 8),
          _tableCell('Messages', 1, flex: true),
          const SizedBox(width: 8),
          Container(
            width: 10,
            padding: const EdgeInsets.only(right: 8),
            alignment: Alignment.centerRight,
            child: Icon(Icons.arrow_upward_rounded,
                size: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _tableCell(String text, double width, {bool flex = false}) {
    final cell = Text(
      text,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
    );
    if (flex) {
      return Expanded(child: cell);
    }
    return SizedBox(width: width, child: cell);
  }

  Widget _buildTableBody() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _logs.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
      itemBuilder: (context, index) {
        final log = _logs[index];
        return _buildTableRow(log);
      },
    );
  }

  Widget _buildTableRow(PackingLog log) {
    final statusColor = _statusColor(log.status);
    final statusIcon = _statusIcon(log.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              _formatTime(log.createdAt),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.itemBarcode,
                  style: AppTextStyles.captionBold.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  log.itemName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    log.status,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: _buildProgressBadge(log.progressPercent),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBadge(double percent) {
    final color = percent >= 100
        ? AppColors.success
        : percent >= 50
            ? AppColors.warning
            : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${percent.round()}%',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
