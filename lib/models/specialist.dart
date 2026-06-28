class Specialist {
  final int? id;
  final String nama;
  final String kode;

  Specialist({this.id, required this.nama, required this.kode});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'kode': kode,
    };
  }

  factory Specialist.fromMap(Map<String, dynamic> map) {
    return Specialist(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      kode: map['kode'] as String,
    );
  }

  Specialist copyWith({int? id, String? nama, String? kode}) {
    return Specialist(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kode: kode ?? this.kode,
    );
  }
}
