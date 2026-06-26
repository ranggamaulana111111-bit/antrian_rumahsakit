class PackingItem {
  final int? id;
  final String namaBarang;
  final String kategori;
  final String prioritas;
  final String tanggalPerjalanan;
  final int statusPacking;
  final String? catatan;
  final String? createdAt;
  final String? updatedAt;

  PackingItem({
    this.id,
    required this.namaBarang,
    required this.kategori,
    required this.prioritas,
    required this.tanggalPerjalanan,
    this.statusPacking = 0,
    this.catatan,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_barang': namaBarang,
      'kategori': kategori,
      'prioritas': prioritas,
      'tanggal_perjalanan': tanggalPerjalanan,
      'status_packing': statusPacking,
      'catatan': catatan ?? '',
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory PackingItem.fromMap(Map<String, dynamic> map) {
    return PackingItem(
      id: map['id'] as int?,
      namaBarang: map['nama_barang'] as String,
      kategori: map['kategori'] as String,
      prioritas: map['prioritas'] as String,
      tanggalPerjalanan: map['tanggal_perjalanan'] as String,
      statusPacking: map['status_packing'] as int? ?? 0,
      catatan: map['catatan'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  PackingItem copyWith({
    int? id,
    String? namaBarang,
    String? kategori,
    String? prioritas,
    String? tanggalPerjalanan,
    int? statusPacking,
    String? catatan,
    String? createdAt,
    String? updatedAt,
  }) {
    return PackingItem(
      id: id ?? this.id,
      namaBarang: namaBarang ?? this.namaBarang,
      kategori: kategori ?? this.kategori,
      prioritas: prioritas ?? this.prioritas,
      tanggalPerjalanan: tanggalPerjalanan ?? this.tanggalPerjalanan,
      statusPacking: statusPacking ?? this.statusPacking,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
