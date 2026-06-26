import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/packing_item.dart';
import '../models/packing_log.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tablePackingItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_barang TEXT NOT NULL,
        kategori TEXT NOT NULL,
        prioritas TEXT NOT NULL,
        tanggal_perjalanan TEXT NOT NULL,
        status_packing INTEGER DEFAULT 0,
        catatan TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ${AppConstants.tablePackingLogs} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        item_barcode TEXT NOT NULL,
        time TEXT NOT NULL,
        status TEXT NOT NULL,
        progress_percent REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES ${AppConstants.tablePackingItems}(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${AppConstants.tablePackingItems} ADD COLUMN updated_at TEXT NOT NULL DEFAULT \'\'',
      );
      await db.execute(
        'UPDATE ${AppConstants.tablePackingItems} SET updated_at = created_at WHERE updated_at = \'\'',
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE ${AppConstants.tablePackingLogs} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_id INTEGER NOT NULL,
          item_name TEXT NOT NULL,
          item_barcode TEXT NOT NULL,
          time TEXT NOT NULL,
          status TEXT NOT NULL,
          progress_percent REAL DEFAULT 0.0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (item_id) REFERENCES ${AppConstants.tablePackingItems}(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<int> insert(PackingItem item) async {
    final db = await database;
    return await db.insert(AppConstants.tablePackingItems, item.toMap());
  }

  Future<List<PackingItem>> getAll({String? orderBy}) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tablePackingItems,
      orderBy: orderBy ?? 'created_at DESC',
    );
    return maps.map((map) => PackingItem.fromMap(map)).toList();
  }

  Future<PackingItem?> getById(int id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tablePackingItems,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PackingItem.fromMap(maps.first);
  }

  Future<List<PackingItem>> getByCategory(String kategori) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tablePackingItems,
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PackingItem.fromMap(map)).toList();
  }

  Future<List<PackingItem>> getByStatus(int statusPacking) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tablePackingItems,
      where: 'status_packing = ?',
      whereArgs: [statusPacking],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PackingItem.fromMap(map)).toList();
  }

  Future<List<PackingItem>> search(String query) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tablePackingItems,
      where: 'nama_barang LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PackingItem.fromMap(map)).toList();
  }

  Future<int> update(PackingItem item) async {
    final db = await database;
    return await db.update(
      AppConstants.tablePackingItems,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tablePackingItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleStatus(int id, int currentStatus, String now) async {
    final db = await database;
    return await db.update(
      AppConstants.tablePackingItems,
      {
        'status_packing': currentStatus == 0 ? 1 : 0,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    final total = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.tablePackingItems}',
      ),
    );
    final packed = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.tablePackingItems} WHERE status_packing = 1',
      ),
    );
    final totalCount = total ?? 0;
    final packedCount = packed ?? 0;
    final percentage = totalCount > 0
        ? (packedCount / totalCount * 100).roundToDouble()
        : 0.0;

    return {
      'total': totalCount,
      'packed': packedCount,
      'unpacked': totalCount - packedCount,
      'percentage': percentage,
    };
  }

  Future<int> getCountByCategory(String kategori) async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.tablePackingItems} WHERE kategori = ?',
        [kategori],
      ),
    ) ?? 0;
  }

  Future<int> bulkInsert(List<PackingItem> items) async {
    final db = await database;
    int count = 0;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(AppConstants.tablePackingItems, item.toMap());
    }
    final results = await batch.commit(noResult: false);
    count = results.length;
    return count;
  }

  Future<int> deleteByCategory(String kategori) async {
    final db = await database;
    return await db.delete(
      AppConstants.tablePackingItems,
      where: 'kategori = ?',
      whereArgs: [kategori],
    );
  }

  Future<int> clearAll() async {
    final db = await database;
    return await db.delete(AppConstants.tablePackingItems);
  }

  Future<int> insertLog(PackingLog log) async {
    final db = await database;
    return await db.insert(AppConstants.tablePackingLogs, log.toMap());
  }

  Future<List<PackingLog>> getAllLogs({String? orderBy}) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tablePackingLogs,
      orderBy: orderBy ?? 'created_at DESC',
    );
    return maps.map((map) => PackingLog.fromMap(map)).toList();
  }

  Future<List<PackingLog>> getLogsByItem(int itemId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tablePackingLogs,
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PackingLog.fromMap(map)).toList();
  }

  Future<PackingLog?> getLatestLog() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tablePackingLogs,
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return PackingLog.fromMap(maps.first);
  }

  Future<Map<String, dynamic>> getLogStats() async {
    final db = await database;
    final total = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.tablePackingLogs}',
      ),
    ) ?? 0;
    final packed = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.tablePackingLogs} WHERE progress_percent = 100.0',
      ),
    ) ?? 0;
    return {
      'total': total,
      'packed': packed,
      'unpacked': total - packed,
    };
  }

  Future<int> clearLogs() async {
    final db = await database;
    return await db.delete(AppConstants.tablePackingLogs);
  }
}
