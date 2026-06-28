import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_constants.dart';
import '../config/app_routes.dart';
import '../repositories/queue_repository.dart';

class QueueListPage extends StatefulWidget {
  const QueueListPage({super.key});

  @override
  State<QueueListPage> createState() => _QueueListPageState();
}

class _QueueListPageState extends State<QueueListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Antrean')),
      body: const QueueListBody(),
    );
  }
}

class QueueListBody extends StatefulWidget {
  const QueueListBody({super.key});

  @override
  State<QueueListBody> createState() => _QueueListBodyState();
}

class _QueueListBodyState extends State<QueueListBody> {
  final QueueRepository _repo = QueueRepository();
  List<Map<String, dynamic>> _queues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueues();
  }

  void _loadQueues() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getAllQueuesWithDetails();
      if (mounted) setState(() { _queues = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Menunggu': return AppColors.orange;
      case 'Dipanggil': return AppColors.primary;
      case 'Selesai': return AppColors.green;
      default: return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Menunggu': return Icons.hourglass_empty;
      case 'Dipanggil': return Icons.volume_up;
      case 'Selesai': return Icons.check_circle;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_queues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.ilustrasiPasien, width: 120, height: 120),
            const SizedBox(height: 16),
            const Text(
              'Belum ada antrean',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadQueues(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _queues.length,
        itemBuilder: (context, index) {
          final q = _queues[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () async {
                final id = q['id'] as int;
                await Navigator.pushNamed(
                  context,
                  AppRoutes.detail,
                  arguments: id,
                );
                _loadQueues();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          (q['nomor_antrean'] as String),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['patient_nama'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${q['doctor_spesialis']} - ${q['doctor_nama']}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(q['tanggal_kunjungan'] as String),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: Icon(
                        _statusIcon(q['status'] as String),
                        size: 16,
                        color: _statusColor(q['status'] as String),
                      ),
                      label: Text(
                        q['status'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: _statusColor(q['status'] as String),
                        ),
                      ),
              backgroundColor: _statusColor(q['status'] as String)
                  .withValues(alpha: 0.1),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
