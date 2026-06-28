import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../config/app_routes.dart';
import '../helpers/database_helper.dart';
import '../models/specialist.dart';

class SpecialistListPage extends StatefulWidget {
  const SpecialistListPage({super.key});

  @override
  State<SpecialistListPage> createState() => _SpecialistListPageState();
}

class _SpecialistListPageState extends State<SpecialistListPage> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Specialist> _specialists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _loading = true);
    try {
      final results = await _db.query('specialists', orderBy: 'nama');
      _specialists = results.map((m) => Specialist.fromMap(m)).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _delete(Specialist s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Poli'),
        content: Text('Hapus ${s.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && s.id != null) {
      await _db.delete('specialists', 'id = ?', [s.id]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poli berhasil dihapus'), behavior: SnackBarBehavior.floating),
        );
      }
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Poli')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.specialistForm);
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _specialists.isEmpty
              ? const Center(child: Text('Belum ada poli'))
              : ListView.builder(
                  itemCount: _specialists.length,
                  itemBuilder: (_, i) {
                    final s = _specialists[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(s.kode, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                        title: Text(s.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Kode: ${s.kode}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.specialistForm,
                                  arguments: s,
                                );
                                if (result == true) _load();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => _delete(s),
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
