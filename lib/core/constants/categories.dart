class PackingCategories {
  PackingCategories._();

  static const List<String> categories = [
    'Dokumen',
    'Pakaian',
    'Peralatan Mandi',
    'Elektronik',
    'Obat-obatan',
  ];

  static const List<String> priorities = [
    'Tinggi',
    'Sedang',
    'Rendah',
  ];

  static const Map<String, List<String>> defaultItems = {
    'Dokumen': [
      'KTP',
      'SIM',
      'Paspor',
      'Tiket',
      'Reservasi Hotel',
      'Kartu Debit',
      'Kartu Kredit',
    ],
    'Pakaian': [
      'Kaos',
      'Celana',
      'Jaket',
      'Pakaian Dalam',
      'Kaus Kaki',
      'Sandal',
      'Sepatu',
    ],
    'Peralatan Mandi': [
      'Sikat Gigi',
      'Pasta Gigi',
      'Sabun',
      'Shampoo',
      'Sunscreen',
      'Deodoran',
      'Tisu',
    ],
    'Elektronik': [
      'Smartphone',
      'Charger',
      'Powerbank',
      'Earphone',
      'Laptop',
    ],
    'Obat-obatan': [
      'Paracetamol',
      'Vitamin',
      'Obat Maag',
      'Obat Flu',
      'Hand Sanitizer',
      'Plester',
    ],
  };
}
