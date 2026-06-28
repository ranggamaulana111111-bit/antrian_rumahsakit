import 'dart:convert';
import 'schedule.dart';

class Doctor {
  final int? id;
  final String namaDokter;
  final String spesialis;
  final List<Schedule> jadwal;

  Doctor({
    this.id,
    required this.namaDokter,
    required this.spesialis,
    required this.jadwal,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_dokter': namaDokter,
      'spesialis': spesialis,
      'jadwal': jsonEncode(jadwal.map((s) => s.toJson()).toList()),
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    final jadwalRaw = map['jadwal'] as String?;
    List<Schedule> parsedJadwal = [];
    if (jadwalRaw != null && jadwalRaw.isNotEmpty) {
      try {
        final list = jsonDecode(jadwalRaw) as List<dynamic>;
        parsedJadwal = list
            .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return Doctor(
      id: map['id'] as int?,
      namaDokter: map['nama_dokter'] as String,
      spesialis: map['spesialis'] as String,
      jadwal: parsedJadwal,
    );
  }

  Doctor copyWith({
    int? id,
    String? namaDokter,
    String? spesialis,
    List<Schedule>? jadwal,
  }) {
    return Doctor(
      id: id ?? this.id,
      namaDokter: namaDokter ?? this.namaDokter,
      spesialis: spesialis ?? this.spesialis,
      jadwal: jadwal ?? this.jadwal,
    );
  }
}
