import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static bool _factoryInitialized = false;

  static void ensureFactory() {
    if (_factoryInitialized) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _factoryInitialized = true;
  }

  Future<Database> get database async {
    ensureFactory();
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mediqueue.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        nik TEXT NOT NULL UNIQUE,
        nomor_hp TEXT NOT NULL,
        jenis_kelamin TEXT NOT NULL,
        tanggal_lahir TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE specialists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL UNIQUE,
        kode TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_dokter TEXT NOT NULL,
        spesialis TEXT NOT NULL,
        jadwal TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE queues (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        nomor_antrean TEXT NOT NULL,
        tanggal_kunjungan TEXT NOT NULL,
        estimasi_waktu TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Menunggu',
        FOREIGN KEY (patient_id) REFERENCES patients(id),
        FOREIGN KEY (doctor_id) REFERENCES doctors(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'pasien',
        nama TEXT NOT NULL,
        patient_id INTEGER,
        FOREIGN KEY (patient_id) REFERENCES patients(id)
      )
    ''');

    await _seedSpecialists(db);
    await _seedDoctors(db);
    await _seedAdmin(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('PRAGMA foreign_keys = OFF');
    try {
      if (oldVersion < 2) {
        await db.delete('queues');
        await db.delete('doctors');
        await _seedDoctors(db);
      }
      if (oldVersion < 3) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS specialists (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL UNIQUE,
            kode TEXT NOT NULL UNIQUE
          )
        ''');
        await _seedSpecialists(db);
      }
      if (oldVersion < 4) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'pasien',
            nama TEXT NOT NULL,
            patient_id INTEGER,
            FOREIGN KEY (patient_id) REFERENCES patients(id)
          )
        ''');
        await _seedAdmin(db);
      }
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _seedAdmin(Database db) async {
    try {
      await db.insert('users', {
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
        'nama': 'Administrator',
        'patient_id': null,
      });
    } catch (_) {}
  }

  Future<void> _seedSpecialists(Database db) async {
    final specialists = [
      {'nama': 'Poli Anak', 'kode': 'A'},
      {'nama': 'Poli Mata', 'kode': 'M'},
      {'nama': 'Poli Jantung', 'kode': 'J'},
      {'nama': 'Poli Gigi', 'kode': 'G'},
      {'nama': 'Poli THT', 'kode': 'T'},
      {'nama': 'Poli Kandungan', 'kode': 'K'},
    ];
    for (final s in specialists) {
      try {
        await db.insert('specialists', s);
      } catch (_) {}
    }
  }

  Future<void> _seedDoctors(Database db) async {
    final doctors = [
      // Poli Anak
      {
        'nama_dokter': 'dr. Fitriani, Sp.A',
        'spesialis': 'Poli Anak',
        'jadwal': '[{"hari":"Senin","jam":"08.00-12.00"},{"hari":"Rabu","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Rahmat Hidayat, Sp.A, M.Kes',
        'spesialis': 'Poli Anak',
        'jadwal': '[{"hari":"Selasa","jam":"13.00-16.00"},{"hari":"Kamis","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Maya Anggraini, Sp.A, Ph.D',
        'spesialis': 'Poli Anak',
        'jadwal': '[{"hari":"Senin","jam":"13.00-16.00"},{"hari":"Jumat","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Hendra Gunawan, Sp.A, M.Biomed',
        'spesialis': 'Poli Anak',
        'jadwal': '[{"hari":"Rabu","jam":"13.00-16.00"},{"hari":"Sabtu","jam":"08.00-12.00"}]',
      },
      // Poli Mata
      {
        'nama_dokter': 'dr. Andi Saputra, Sp.M',
        'spesialis': 'Poli Mata',
        'jadwal': '[{"hari":"Senin","jam":"08.00-12.00"},{"hari":"Kamis","jam":"13.00-16.00"}]',
      },
      {
        'nama_dokter': 'dr. Siti Rahma, Sp.M, M.Kes',
        'spesialis': 'Poli Mata',
        'jadwal': '[{"hari":"Selasa","jam":"08.00-12.00"},{"hari":"Jumat","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Bambang Wijaya, Sp.M, M.Biomed',
        'spesialis': 'Poli Mata',
        'jadwal': '[{"hari":"Senin","jam":"13.00-16.00"},{"hari":"Rabu","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Ratna Dewi, Sp.M, Ph.D',
        'spesialis': 'Poli Mata',
        'jadwal': '[{"hari":"Kamis","jam":"08.00-12.00"},{"hari":"Sabtu","jam":"08.00-12.00"}]',
      },
      // Poli Jantung
      {
        'nama_dokter': 'dr. Budi Hartono, Sp.JP',
        'spesialis': 'Poli Jantung',
        'jadwal': '[{"hari":"Senin","jam":"13.00-16.00"},{"hari":"Rabu","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Dewa Pratama, Sp.JP, FIHA',
        'spesialis': 'Poli Jantung',
        'jadwal': '[{"hari":"Selasa","jam":"08.00-12.00"},{"hari":"Kamis","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Kristina Wulandari, Sp.JP, Ph.D, FIHA',
        'spesialis': 'Poli Jantung',
        'jadwal': '[{"hari":"Senin","jam":"08.00-12.00"},{"hari":"Jumat","jam":"13.00-16.00"}]',
      },
      {
        'nama_dokter': 'dr. Ari Pramono, Sp.JP, M.Kes',
        'spesialis': 'Poli Jantung',
        'jadwal': '[{"hari":"Rabu","jam":"13.00-16.00"},{"hari":"Sabtu","jam":"08.00-12.00"}]',
      },
      // Poli Gigi
      {
        'nama_dokter': 'drg. Anita Wulandari, Sp.KG',
        'spesialis': 'Poli Gigi',
        'jadwal': '[{"hari":"Senin","jam":"08.00-12.00"},{"hari":"Jumat","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'drg. Teguh Santoso, Sp.BM',
        'spesialis': 'Poli Gigi',
        'jadwal': '[{"hari":"Rabu","jam":"13.00-16.00"},{"hari":"Sabtu","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'drg. Putri Maharani, Sp.Ort',
        'spesialis': 'Poli Gigi',
        'jadwal': '[{"hari":"Selasa","jam":"08.00-12.00"},{"hari":"Kamis","jam":"13.00-16.00"}]',
      },
      {
        'nama_dokter': 'drg. Dimas Prayoga, Sp.Perio, M.Kes',
        'spesialis': 'Poli Gigi',
        'jadwal': '[{"hari":"Senin","jam":"13.00-16.00"},{"hari":"Rabu","jam":"08.00-12.00"}]',
      },
      // Poli THT
      {
        'nama_dokter': 'dr. Nina Mariana, Sp.THT-KL',
        'spesialis': 'Poli THT',
        'jadwal': '[{"hari":"Selasa","jam":"08.00-12.00"},{"hari":"Kamis","jam":"13.00-16.00"}]',
      },
      {
        'nama_dokter': 'dr. Fajar Ardiansyah, Sp.THT-KL',
        'spesialis': 'Poli THT',
        'jadwal': '[{"hari":"Senin","jam":"13.00-16.00"},{"hari":"Rabu","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Rina Amelia, Sp.THT-KL, M.Kes',
        'spesialis': 'Poli THT',
        'jadwal': '[{"hari":"Senin","jam":"08.00-12.00"},{"hari":"Jumat","jam":"13.00-16.00"}]',
      },
      {
        'nama_dokter': 'dr. Andika Pratama, Sp.THT-KL, Ph.D',
        'spesialis': 'Poli THT',
        'jadwal': '[{"hari":"Rabu","jam":"13.00-16.00"},{"hari":"Sabtu","jam":"08.00-12.00"}]',
      },
      // Poli Kandungan
      {
        'nama_dokter': 'dr. Sri Wahyuni, Sp.OG',
        'spesialis': 'Poli Kandungan',
        'jadwal': '[{"hari":"Senin","jam":"08.00-12.00"},{"hari":"Rabu","jam":"13.00-16.00"}]',
      },
      {
        'nama_dokter': 'dr. Agus Pranoto, Sp.OG, M.Kes',
        'spesialis': 'Poli Kandungan',
        'jadwal': '[{"hari":"Selasa","jam":"08.00-12.00"},{"hari":"Jumat","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Dewi Sartika, Sp.OG, Ph.D',
        'spesialis': 'Poli Kandungan',
        'jadwal': '[{"hari":"Senin","jam":"13.00-16.00"},{"hari":"Kamis","jam":"08.00-12.00"}]',
      },
      {
        'nama_dokter': 'dr. Rizky Firmansyah, Sp.OG, M.Biomed',
        'spesialis': 'Poli Kandungan',
        'jadwal': '[{"hari":"Selasa","jam":"13.00-16.00"},{"hari":"Jumat","jam":"08.00-12.00"}]',
      },
    ];

    for (final doctor in doctors) {
      await db.insert('doctors', doctor);
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    final db = await database;
    final results = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql,
    List<dynamic>? arguments,
  ) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
}
