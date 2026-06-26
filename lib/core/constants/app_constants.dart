class AppConstants {
  AppConstants._();

  static const String appName = 'TravelPack';
  static const String appTagline = 'Pack Smarter, Travel Better';

  static const String dbName = 'travelpack.db';
  static const int dbVersion = 3;

  static const String tablePackingItems = 'packing_items';
  static const String tablePackingLogs = 'packing_logs';

  static const List<String> tableColumns = [
    'id',
    'nama_barang',
    'kategori',
    'prioritas',
    'tanggal_perjalanan',
    'status_packing',
    'catatan',
    'created_at',
    'updated_at',
  ];

  static const String validUsername = 'ADMIN';
  static const String validPassword = 'ADMIN';

  static const int splashDurationSeconds = 3;
}
