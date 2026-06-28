class Schedule {
  final String hari;
  final String jam;

  Schedule({required this.hari, required this.jam});

  Map<String, dynamic> toJson() => {'hari': hari, 'jam': jam};

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      hari: json['hari'] as String,
      jam: json['jam'] as String,
    );
  }

  @override
  String toString() => '$hari $jam';
}
