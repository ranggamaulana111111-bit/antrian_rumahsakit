import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../helpers/database_helper.dart';
import '../models/doctor.dart';
import '../models/schedule.dart';
import '../models/specialist.dart';

class DoctorFormPage extends StatefulWidget {
  final Doctor? doctor;
  const DoctorFormPage({super.key, this.doctor});

  @override
  State<DoctorFormPage> createState() => _DoctorFormPageState();
}

class _DoctorFormPageState extends State<DoctorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper();

  String? _selectedSpesialis;
  List<Specialist> _specialists = [];
  List<Schedule> _schedules = [];

  bool get _isEditing => widget.doctor != null;

  static const List<String> _hariList = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const List<String> _jamList = [
    '08.00-12.00', '13.00-16.00',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpecialists();
    if (_isEditing) {
      _namaController.text = widget.doctor!.namaDokter;
      _selectedSpesialis = widget.doctor!.spesialis;
      _schedules = List.from(widget.doctor!.jadwal);
    }
  }

  void _loadSpecialists() async {
    try {
      final results = await _db.query('specialists', orderBy: 'nama');
      _specialists = results.map((m) => Specialist.fromMap(m)).toList();
      if (!_isEditing && _specialists.isNotEmpty) {
        _selectedSpesialis ??= _specialists.first.nama;
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _addSchedule() {
    showDialog(
      context: context,
      builder: (ctx) {
        String selectedHari = _hariList.first;
        String selectedJam = _jamList.first;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Tambah Jadwal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedHari,
                  decoration: const InputDecoration(labelText: 'Hari'),
                  items: _hariList
                      .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedHari = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedJam,
                  decoration: const InputDecoration(labelText: 'Jam'),
                  items: _jamList
                      .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedJam = v!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _schedules.add(Schedule(hari: selectedHari, jam: selectedJam)));
                  Navigator.pop(ctx);
                },
                child: const Text('Tambah'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpesialis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih spesialis'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambah minimal 1 jadwal'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final doctor = Doctor(
      id: widget.doctor?.id,
      namaDokter: _namaController.text.trim(),
      spesialis: _selectedSpesialis!,
      jadwal: _schedules,
    );

    if (_isEditing) {
      await _db.update('doctors', doctor.toMap(), 'id = ?', [widget.doctor!.id]);
    } else {
      await _db.insert('doctors', doctor.toMap());
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Dokter' : 'Tambah Dokter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Dokter'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSpesialis,
                decoration: const InputDecoration(labelText: 'Spesialis / Poli'),
                items: _specialists
                    .map((s) => DropdownMenuItem(value: s.nama, child: Text(s.nama)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSpesialis = v),
                validator: (v) => v == null ? 'Pilih spesialis' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jadwal Praktik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton.icon(
                    onPressed: _addSchedule,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              if (_schedules.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Belum ada jadwal', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ..._schedules.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text('${s.hari} ${s.jam}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => setState(() => _schedules.removeAt(i)),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
