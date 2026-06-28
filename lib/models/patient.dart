class Patient {
  final int? id;
  final String nama;
  final String nik;
  final String nomorHp;
  final String jenisKelamin;
  final String tanggalLahir;

  Patient({
    this.id,
    required this.nama,
    required this.nik,
    required this.nomorHp,
    required this.jenisKelamin,
    required this.tanggalLahir,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'nik': nik,
      'nomor_hp': nomorHp,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      nik: map['nik'] as String,
      nomorHp: map['nomor_hp'] as String,
      jenisKelamin: map['jenis_kelamin'] as String,
      tanggalLahir: map['tanggal_lahir'] as String,
    );
  }

  Patient copyWith({
    int? id,
    String? nama,
    String? nik,
    String? nomorHp,
    String? jenisKelamin,
    String? tanggalLahir,
  }) {
    return Patient(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nik: nik ?? this.nik,
      nomorHp: nomorHp ?? this.nomorHp,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
    );
  }
}
