class Queue {
  final int? id;
  final int patientId;
  final int doctorId;
  final String nomorAntrean;
  final String tanggalKunjungan;
  final String estimasiWaktu;
  final String status;

  Queue({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.nomorAntrean,
    required this.tanggalKunjungan,
    required this.estimasiWaktu,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'nomor_antrean': nomorAntrean,
      'tanggal_kunjungan': tanggalKunjungan,
      'estimasi_waktu': estimasiWaktu,
      'status': status,
    };
  }

  factory Queue.fromMap(Map<String, dynamic> map) {
    return Queue(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      doctorId: map['doctor_id'] as int,
      nomorAntrean: map['nomor_antrean'] as String,
      tanggalKunjungan: map['tanggal_kunjungan'] as String,
      estimasiWaktu: map['estimasi_waktu'] as String,
      status: map['status'] as String,
    );
  }

  Queue copyWith({
    int? id,
    int? patientId,
    int? doctorId,
    String? nomorAntrean,
    String? tanggalKunjungan,
    String? estimasiWaktu,
    String? status,
  }) {
    return Queue(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      nomorAntrean: nomorAntrean ?? this.nomorAntrean,
      tanggalKunjungan: tanggalKunjungan ?? this.tanggalKunjungan,
      estimasiWaktu: estimasiWaktu ?? this.estimasiWaktu,
      status: status ?? this.status,
    );
  }
}
