class PackingLog {
  final int? id;
  final int itemId;
  final String itemName;
  final String itemBarcode;
  final String time;
  final String status;
  final double progressPercent;
  final String? createdAt;

  PackingLog({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.itemBarcode,
    required this.time,
    required this.status,
    this.progressPercent = 0.0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'item_barcode': itemBarcode,
      'time': time,
      'status': status,
      'progress_percent': progressPercent,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory PackingLog.fromMap(Map<String, dynamic> map) {
    return PackingLog(
      id: map['id'] as int?,
      itemId: map['item_id'] as int,
      itemName: map['item_name'] as String,
      itemBarcode: map['item_barcode'] as String,
      time: map['time'] as String,
      status: map['status'] as String,
      progressPercent: (map['progress_percent'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] as String?,
    );
  }

  PackingLog copyWith({
    int? id,
    int? itemId,
    String? itemName,
    String? itemBarcode,
    String? time,
    String? status,
    double? progressPercent,
    String? createdAt,
  }) {
    return PackingLog(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemBarcode: itemBarcode ?? this.itemBarcode,
      time: time ?? this.time,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
