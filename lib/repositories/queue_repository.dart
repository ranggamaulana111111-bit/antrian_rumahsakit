import '../helpers/database_helper.dart';
import '../helpers/queue_number_helper.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/queue.dart';

class QueueRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<Patient?> getPatientByNik(String nik) async {
    final results = await _db.query(
      'patients',
      where: 'nik = ?',
      whereArgs: [nik],
    );
    if (results.isEmpty) return null;
    return Patient.fromMap(results.first);
  }

  Future<Patient> insertPatient(Patient patient) async {
    final existing = await getPatientByNik(patient.nik);
    if (existing != null) return existing;

    final id = await _db.insert('patients', patient.toMap());
    return patient.copyWith(id: id);
  }

  Future<Patient?> getPatientById(int id) async {
    final result = await _db.queryById('patients', id);
    if (result == null) return null;
    return Patient.fromMap(result);
  }

  Future<List<Patient>> getAllPatients() async {
    final results = await _db.query('patients', orderBy: 'id DESC');
    return results.map((map) => Patient.fromMap(map)).toList();
  }

  Future<Doctor?> getDoctorById(int id) async {
    final result = await _db.queryById('doctors', id);
    if (result == null) return null;
    return Doctor.fromMap(result);
  }

  Future<List<Doctor>> getAllDoctors() async {
    final results = await _db.query('doctors', orderBy: 'spesialis, nama_dokter');
    return results.map((map) => Doctor.fromMap(map)).toList();
  }

  Future<List<Doctor>> getDoctorsBySpesialis(String spesialis) async {
    final results = await _db.query(
      'doctors',
      where: 'spesialis = ?',
      whereArgs: [spesialis],
      orderBy: 'nama_dokter',
    );
    return results.map((map) => Doctor.fromMap(map)).toList();
  }

  Future<Queue> insertQueue(Queue queue) async {
    final id = await _db.insert('queues', queue.toMap());
    return queue.copyWith(id: id);
  }

  Future<List<Queue>> getAllQueues() async {
    final results = await _db.query('queues', orderBy: 'id DESC');
    return results.map((map) => Queue.fromMap(map)).toList();
  }

  Future<List<Queue>> getQueuesByDate(String date) async {
    final results = await _db.query(
      'queues',
      where: 'tanggal_kunjungan = ?',
      whereArgs: [date],
      orderBy: 'id ASC',
    );
    return results.map((map) => Queue.fromMap(map)).toList();
  }

  Future<Queue?> getQueueById(int id) async {
    final result = await _db.queryById('queues', id);
    if (result == null) return null;
    return Queue.fromMap(result);
  }

  Future<int> updateQueue(Queue queue) async {
    return await _db.update(
      'queues',
      queue.toMap(),
      'id = ?',
      [queue.id],
    );
  }

  Future<int> updateQueueStatus(int id, String status) async {
    return await _db.update(
      'queues',
      {'status': status},
      'id = ?',
      [id],
    );
  }

  Future<int> deleteQueue(int id) async {
    return await _db.delete('queues', 'id = ?', [id]);
  }

  Future<String> getNextQueueNumber(String poliName, String date) async {
    final code = QueueNumberHelper.getCode(poliName);

    final results = await _db.query(
      'queues',
      where: 'nomor_antrean LIKE ? AND tanggal_kunjungan = ?',
      whereArgs: ['$code%', date],
      orderBy: 'id DESC',
    );

    int lastCounter = 0;
    if (results.isNotEmpty) {
      final lastNumber = results.first['nomor_antrean'] as String;
      lastCounter = QueueNumberHelper.extractNumber(lastNumber);
    }

    return QueueNumberHelper.generate(poliName, lastCounter);
  }

  Future<String> calculateEstimasi(int doctorId, String date) async {
    final results = await _db.query(
      'queues',
      where: 'doctor_id = ? AND tanggal_kunjungan = ?',
      whereArgs: [doctorId, date],
      orderBy: 'id ASC',
    );

    final estimasiPerPasien = 15;
    final totalMenit = results.length * estimasiPerPasien;
    final jam = (totalMenit ~/ 60).toString().padLeft(2, '0');
    final menit = (totalMenit % 60).toString().padLeft(2, '0');
    return '$jam:$menit';
  }

  Future<Map<String, dynamic>?> getQueueDetail(int queueId) async {
    final db = await _db.database;
    final results = await db.rawQuery('''
      SELECT
        q.id,
        q.nomor_antrean,
        q.tanggal_kunjungan,
        q.estimasi_waktu,
        q.status,
        p.id AS patient_id,
        p.nama AS patient_nama,
        p.nik AS patient_nik,
        p.nomor_hp AS patient_nomor_hp,
        p.jenis_kelamin AS patient_jenis_kelamin,
        p.tanggal_lahir AS patient_tanggal_lahir,
        d.id AS doctor_id,
        d.nama_dokter AS doctor_nama,
        d.spesialis AS doctor_spesialis,
        d.jadwal AS doctor_jadwal
      FROM queues q
      INNER JOIN patients p ON q.patient_id = p.id
      INNER JOIN doctors d ON q.doctor_id = d.id
      WHERE q.id = ?
    ''', [queueId]);

    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllQueuesWithDetails() async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT
        q.id,
        q.nomor_antrean,
        q.tanggal_kunjungan,
        q.estimasi_waktu,
        q.status,
        p.nama AS patient_nama,
        d.nama_dokter AS doctor_nama,
        d.spesialis AS doctor_spesialis
      FROM queues q
      INNER JOIN patients p ON q.patient_id = p.id
      INNER JOIN doctors d ON q.doctor_id = d.id
      ORDER BY q.id DESC
    ''');
  }

  Future<List<Queue>> getQueuesByPatientId(int patientId) async {
    final results = await _db.query(
      'queues',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'id DESC',
    );
    return results.map((map) => Queue.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getQueuesByPatientIdWithDetails(
      int patientId) async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT
        q.id,
        q.nomor_antrean,
        q.tanggal_kunjungan,
        q.estimasi_waktu,
        q.status,
        p.nama AS patient_nama,
        d.nama_dokter AS doctor_nama,
        d.spesialis AS doctor_spesialis
      FROM queues q
      INNER JOIN patients p ON q.patient_id = p.id
      INNER JOIN doctors d ON q.doctor_id = d.id
      WHERE q.patient_id = ?
      ORDER BY q.id DESC
    ''', [patientId]);
  }

  Future<bool> hasQueueForPatientToday(int patientId, String date) async {
    final results = await _db.query(
      'queues',
      where: 'patient_id = ? AND tanggal_kunjungan = ?',
      whereArgs: [patientId, date],
    );
    return results.isNotEmpty;
  }
}
