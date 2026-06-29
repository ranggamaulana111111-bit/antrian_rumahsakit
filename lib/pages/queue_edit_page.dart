import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_constants.dart';
import '../repositories/queue_repository.dart';
import '../models/doctor.dart';
import '../models/specialist.dart';
import '../helpers/database_helper.dart';

class QueueEditPage extends StatefulWidget {
  final int? queueId;
  const QueueEditPage({super.key, this.queueId});

  @override
  State<QueueEditPage> createState() => _QueueEditPageState();
}

class _QueueEditPageState extends State<QueueEditPage> {
  final QueueRepository _repo = QueueRepository();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSubmitting = false;

  Map<String, dynamic>? _detail;

  String? _selectedPoli;
  String? _selectedDoctorId;
  Doctor? _selectedDoctor;
  String? _selectedSchedule;
  DateTime _visitDate = DateTime.now();
  List<Doctor> _allDoctors = [];
  List<String> _poliList = PoliData.poliList;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final specialists = await DatabaseHelper()
          .query('specialists', orderBy: 'nama');
      if (specialists.isNotEmpty) {
        _poliList =
            specialists.map((m) => Specialist.fromMap(m).nama).toList();
      }
      _allDoctors = await _repo.getAllDoctors();
    } catch (_) {}

    if (widget.queueId != null) {
      final detail = await _repo.getQueueDetail(widget.queueId!);
      if (detail != null) {
        _detail = detail;
        _selectedPoli = detail['doctor_spesialis'] as String;
        _visitDate = DateTime.parse(detail['tanggal_kunjungan'] as String);
        _selectedDoctorId = detail['doctor_id'].toString();
        _selectedDoctor = _allDoctors
            .where((d) => d.id.toString() == _selectedDoctorId)
            .firstOrNull;
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
  String _iso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  List<Doctor> get _doctorsForPoli {
    if (_selectedPoli == null) return [];
    return _allDoctors.where((d) => d.spesialis == _selectedPoli).toList();
  }

  List<String> get _scheduleLabels {
    if (_selectedDoctor == null) return [];
    return _selectedDoctor!.jadwal.map((s) => s.toString()).toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.queueId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final dateStr = _iso(_visitDate);
      final estimasi = await _repo.calculateEstimasi(
        _selectedDoctor!.id!,
        dateStr,
      );

      await _repo.updateQueueStatus(widget.queueId!, 'Menunggu');

      await DatabaseHelper().update(
        'queues',
        {
          'doctor_id': _selectedDoctor!.id,
          'tanggal_kunjungan': dateStr,
          'estimasi_waktu': estimasi,
          'status': 'Menunggu',
        },
        'id = ?',
        [widget.queueId],
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Antrean berhasil diubah'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah antrean: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Antrean')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_detail != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _detail!['nomor_antrean'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _detail!['patient_nama'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _detail!['doctor_spesialis'] as String,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Pilih Poli',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPoli,
                      decoration: const InputDecoration(
                        labelText: 'Poli',
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      items: _poliList.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedPoli = v;
                          _selectedDoctorId = null;
                          _selectedDoctor = null;
                          _selectedSchedule = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pilih Dokter',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._doctorsForPoli.map((d) {
                      final selected = _selectedDoctorId == d.id.toString();
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: selected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDoctorId = d.id.toString();
                              _selectedDoctor = d;
                              _selectedSchedule = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d.namaDokter,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        d.spesialis,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_doctorsForPoli.isEmpty && _selectedPoli != null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Tidak ada dokter untuk poli ini',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Jadwal & Tanggal',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Tanggal Kunjungan: '),
                        TextButton.icon(
                          onPressed: _pickVisitDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_fmt(_visitDate)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_selectedDoctor != null)
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSchedule,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Jadwal',
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        items: _scheduleLabels.map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedSchedule = v),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(color: AppColors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
