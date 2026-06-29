import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_constants.dart';
import '../config/app_routes.dart';
import '../repositories/queue_repository.dart';
import '../services/auth_service.dart';

class QueueDetailPage extends StatefulWidget {
  final int? queueId;

  const QueueDetailPage({super.key, this.queueId});

  @override
  State<QueueDetailPage> createState() => _QueueDetailPageState();
}

class _QueueDetailPageState extends State<QueueDetailPage> {
  final QueueRepository _repo = QueueRepository();
  final AuthService _auth = AuthService();
  Map<String, dynamic>? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() async {
    if (widget.queueId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final data = await _repo.getQueueDetail(widget.queueId!);
    if (mounted) setState(() { _detail = data; _isLoading = false; });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Menunggu': return AppColors.orange;
      case 'Dipanggil': return AppColors.primary;
      case 'Selesai': return AppColors.green;
      default: return AppColors.textSecondary;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (widget.queueId == null) return;
    try {
      await _repo.updateQueueStatus(widget.queueId!, newStatus);
      _loadDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status diubah menjadi $newStatus'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteQueue() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Antrean'),
        content: const Text('Apakah Anda yakin ingin menghapus antrean ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.queueId != null) {
      try {
        await _repo.deleteQueue(widget.queueId!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Antrean berhasil dihapus'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus antrean'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Antrean'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteQueue,
            tooltip: 'Hapus antrean',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_detail == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    final d = _detail!;
    final status = d['status'] as String;
    final isAdmin = _auth.isAdmin;

    return RefreshIndicator(
      onRefresh: () async => _loadDetail(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(d),
            const SizedBox(height: 16),
            _buildInfoCard('Data Pasien', [
              _infoRow('Nama', d['patient_nama'] as String),
              _infoRow('NIK', d['patient_nik'] as String),
              _infoRow('No. HP', d['patient_nomor_hp'] as String),
              _infoRow('Jenis Kelamin', d['patient_jenis_kelamin'] as String),
              _infoRow(
                'Tanggal Lahir',
                _formatDate(d['patient_tanggal_lahir'] as String),
              ),
            ]),
            const SizedBox(height: 12),
            _buildInfoCard('Data Dokter', [
              _infoRow('Nama Dokter', d['doctor_nama'] as String),
              _infoRow('Spesialis', d['doctor_spesialis'] as String),
            ]),
            const SizedBox(height: 12),
            _buildInfoCard('Detail Antrean', [
              _infoRow('Tanggal', _formatDate(d['tanggal_kunjungan'] as String)),
              _infoRow('Estimasi', d['estimasi_waktu'] as String),
            ]),
            const SizedBox(height: 24),
            _buildStatusActions(status, isAdmin),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> d) {
    final status = d['status'] as String;
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary,
        ),
        child: Column(
          children: [
            Text(
              d['nomor_antrean'] as String,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: _statusColor(status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions(String currentStatus, bool isAdmin) {
    if (currentStatus == 'Selesai') {
      if (!isAdmin) return const SizedBox.shrink();
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isAdmin && currentStatus == 'Menunggu')
          ElevatedButton.icon(
            onPressed: () => _updateStatus('Dipanggil'),
            icon: const Icon(Icons.volume_up),
            label: const Text('Tandai Dipanggil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        if (isAdmin && currentStatus == 'Dipanggil')
          ElevatedButton.icon(
            onPressed: () => _updateStatus('Selesai'),
            icon: const Icon(Icons.check_circle),
            label: const Text('Tandai Selesai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        if (isAdmin && currentStatus != 'Selesai') ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.editAntrean,
                arguments: widget.queueId,
              );
              _loadDetail();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Antrean'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
        if (!isAdmin && currentStatus == 'Menunggu') ...[
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.editAntrean,
                arguments: widget.queueId,
              );
              _loadDetail();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Ubah Antrean'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
        if (currentStatus == 'Menunggu') ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _deleteQueue,
            icon: const Icon(Icons.cancel),
            label: const Text('Batalkan Antrean'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}
