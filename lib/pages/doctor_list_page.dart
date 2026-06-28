import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../config/app_routes.dart';
import '../helpers/database_helper.dart';
import '../models/doctor.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Doctor> _doctors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  void _loadDoctors() async {
    setState(() => _loading = true);
    try {
      final results = await _db.query('doctors', orderBy: 'spesialis, nama_dokter');
      _doctors = results.map((m) => Doctor.fromMap(m)).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deleteDoctor(Doctor doctor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dokter'),
        content: Text('Hapus ${doctor.namaDokter}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && doctor.id != null) {
      await _db.delete('doctors', 'id = ?', [doctor.id]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dokter berhasil dihapus'), behavior: SnackBarBehavior.floating),
        );
      }
      _loadDoctors();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Dokter')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.doctorForm);
          if (result == true) _loadDoctors();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? const Center(child: Text('Belum ada dokter'))
              : ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (_, i) {
                    final d = _doctors[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        title: Text(d.namaDokter, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${d.spesialis}\n${d.jadwal.map((s) => s.toString()).join(', ')}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.doctorForm,
                                  arguments: d,
                                );
                                if (result == true) _loadDoctors();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => _deleteDoctor(d),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
