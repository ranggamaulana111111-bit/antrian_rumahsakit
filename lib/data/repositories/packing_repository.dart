import '../database/database_helper.dart';
import '../models/packing_item.dart';
import '../models/packing_log.dart';
import '../../core/constants/categories.dart';

class PackingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<PackingItem>> getAll({String? orderBy}) async {
    return await _dbHelper.getAll(orderBy: orderBy);
  }

  Future<PackingItem?> getById(int id) async {
    return await _dbHelper.getById(id);
  }

  Future<List<PackingItem>> getByCategory(String kategori) async {
    return await _dbHelper.getByCategory(kategori);
  }

  Future<List<PackingItem>> getByStatus(bool isPacked) async {
    return await _dbHelper.getByStatus(isPacked ? 1 : 0);
  }

  Future<List<PackingItem>> search(String query) async {
    if (query.trim().isEmpty) return await getAll();
    return await _dbHelper.search(query.trim());
  }

  Future<int> addItem({
    required String namaBarang,
    required String kategori,
    required String prioritas,
    required String tanggalPerjalanan,
    int statusPacking = 0,
    String? catatan,
  }) async {
    final now = DateTime.now().toIso8601String();
    final item = PackingItem(
      namaBarang: namaBarang.trim(),
      kategori: kategori,
      prioritas: prioritas,
      tanggalPerjalanan: tanggalPerjalanan,
      statusPacking: statusPacking,
      catatan: catatan?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    return await _dbHelper.insert(item);
  }

  Future<int> updateItem({
    required int id,
    required String namaBarang,
    required String kategori,
    required String prioritas,
    required String tanggalPerjalanan,
    int statusPacking = 0,
    String? catatan,
  }) async {
    final now = DateTime.now().toIso8601String();
    final existing = await _dbHelper.getById(id);
    if (existing == null) return 0;

    final updated = existing.copyWith(
      namaBarang: namaBarang.trim(),
      kategori: kategori,
      prioritas: prioritas,
      tanggalPerjalanan: tanggalPerjalanan,
      statusPacking: statusPacking,
      catatan: catatan?.trim(),
      updatedAt: now,
    );
    return await _dbHelper.update(updated);
  }

  Future<int> deleteItem(int id) async {
    return await _dbHelper.delete(id);
  }

  Future<int> toggleStatus(int id, int currentStatus) async {
    final now = DateTime.now().toIso8601String();
    final result = await _dbHelper.toggleStatus(id, currentStatus, now);

    final item = await _dbHelper.getById(id);
    if (item != null) {
      final stats = await _dbHelper.getStats();
      final total = stats['total'] as int? ?? 0;
      final packed = stats['packed'] as int? ?? 0;
      final percent = total > 0 ? (packed / total * 100) : 0.0;

      final newStatus = currentStatus == 0 ? 1 : 0;
      String statusText;
      if (newStatus == 1) {
        if (percent >= 100.0) {
          statusText = 'Packing completed 100%';
        } else {
          statusText = 'Packing completed ${percent.round()}%';
        }
      } else {
        statusText = 'Pending weight check';
      }

      await _dbHelper.insertLog(PackingLog(
        itemId: item.id!,
        itemName: item.namaBarang,
        itemBarcode: item.namaBarang.toUpperCase().replaceAll(' ', '-'),
        time: now,
        status: statusText,
        progressPercent: percent,
        createdAt: now,
      ));
    }

    return result;
  }

  Future<Map<String, dynamic>> getStats() async {
    return await _dbHelper.getStats();
  }

  Future<List<PackingLog>> getAllLogs() async {
    return await _dbHelper.getAllLogs();
  }

  Future<List<PackingLog>> getLogsByItem(int itemId) async {
    return await _dbHelper.getLogsByItem(itemId);
  }

  Future<PackingLog?> getLatestLog() async {
    return await _dbHelper.getLatestLog();
  }

  Future<Map<String, dynamic>> getLogStats() async {
    return await _dbHelper.getLogStats();
  }

  Future<int> addDefaultItemsForCategory(String kategori) async {
    final defaults = PackingCategories.defaultItems[kategori];
    if (defaults == null || defaults.isEmpty) return 0;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final now = DateTime.now().toIso8601String();

    final items = defaults.map((name) => PackingItem(
          namaBarang: name,
          kategori: kategori,
          prioritas: 'Sedang',
          tanggalPerjalanan: today,
          statusPacking: 0,
          createdAt: now,
          updatedAt: now,
        )).toList();

    return await _dbHelper.bulkInsert(items);
  }

  Future<int> getCountByCategory(String kategori) async {
    return await _dbHelper.getCountByCategory(kategori);
  }

  Future<int> deleteByCategory(String kategori) async {
    return await _dbHelper.deleteByCategory(kategori);
  }

  Future<int> clearAll() async {
    return await _dbHelper.clearAll();
  }
}
