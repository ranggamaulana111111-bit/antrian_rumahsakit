class User {
  final int? id;
  final String username;
  final String password;
  final String role;
  final String nama;
  final int? patientId;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.nama,
    this.patientId,
  });

  bool get isAdmin => role == 'admin';
  bool get isPasien => role == 'pasien';

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'role': role,
      'nama': nama,
      'patient_id': patientId,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      nama: map['nama'] as String,
      patientId: map['patient_id'] as int?,
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
    String? nama,
    int? patientId,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      nama: nama ?? this.nama,
      patientId: patientId ?? this.patientId,
    );
  }
}
