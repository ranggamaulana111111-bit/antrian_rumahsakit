import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/specialist.dart';

class SpecialistFormPage extends StatefulWidget {
  final Specialist? specialist;
  const SpecialistFormPage({super.key, this.specialist});

  @override
  State<SpecialistFormPage> createState() => _SpecialistFormPageState();
}

class _SpecialistFormPageState extends State<SpecialistFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kodeController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper();

  bool get _isEditing => widget.specialist != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _namaController.text = widget.specialist!.nama;
      _kodeController.text = widget.specialist!.kode;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nama = _namaController.text.trim();
    final kode = _kodeController.text.trim().toUpperCase();

    final data = {
      'nama': nama,
      'kode': kode,
    };

    try {
      if (_isEditing) {
        await _db.update('specialists', data, 'id = ?', [widget.specialist!.id]);
      } else {
        await _db.insert('specialists', data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Poli' : 'Tambah Poli')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Poli'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kodeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Poli',
                  helperText: 'Contoh: A, M, J, G, T, K (1 huruf)',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Kode wajib diisi';
                  if (v.trim().length != 1) return 'Kode harus 1 karakter';
                  return null;
                },
                textCapitalization: TextCapitalization.characters,
              ),
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
