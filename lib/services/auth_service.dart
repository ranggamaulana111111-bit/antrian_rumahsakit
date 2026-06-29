import '../models/user.dart';
import '../helpers/database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isPasien => _currentUser?.isPasien ?? false;

  final DatabaseHelper _db = DatabaseHelper();

  Future<User?> login(String username, String password) async {
    final results = await _db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (results.isEmpty) return null;

    _currentUser = User.fromMap(results.first);
    return _currentUser;
  }

  Future<User> register({
    required String username,
    required String password,
    required String nama,
    String? nik,
    String? nomorHp,
    String? jenisKelamin,
    String? tanggalLahir,
  }) async {
    int? patientId;

    if (nik != null && nik.isNotEmpty) {
      final patientData = {
        'nama': nama,
        'nik': nik,
        'nomor_hp': nomorHp ?? '',
        'jenis_kelamin': jenisKelamin ?? 'Laki-laki',
        'tanggal_lahir': tanggalLahir ?? '',
      };
      patientId = await _db.insert('patients', patientData);
    }

    final userData = {
      'username': username,
      'password': password,
      'role': 'pasien',
      'nama': nama,
      'patient_id': patientId,
    };

    final id = await _db.insert('users', userData);
    _currentUser = User(
      id: id,
      username: username,
      password: password,
      role: 'pasien',
      nama: nama,
      patientId: patientId,
    );
    return _currentUser!;
  }

  void logout() {
    _currentUser = null;
  }

  Future<User?> getUserById(int id) async {
    final result = await _db.queryById('users', id);
    if (result == null) return null;
    return User.fromMap(result);
  }
}
