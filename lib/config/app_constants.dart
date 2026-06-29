import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primarySurface = Color(0xFFE3F2FD);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFF8E1);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color green = Color(0xFF43A047);
  static const Color greenLight = Color(0xFFE8F5E9);
  static const Color orange = Color(0xFFFF9800);
  static const Color orangeLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color shadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color gradientStart = Color(0xFF1565C0);
  static const Color gradientEnd = Color(0xFF1E88E5);
  static const Color gradientGoldStart = Color(0xFFD4AF37);
  static const Color gradientGoldEnd = Color(0xFFF5D76E);

  static const List<Color> primaryGradient = [
    gradientStart,
    gradientEnd,
  ];
  static const List<Color> goldGradient = [
    gradientGoldStart,
    gradientGoldEnd,
  ];
}

class AppAssets {
  static const String logoApp = 'assets/images/logo_app.png';
  static const String logoUnpam = 'assets/images/logo_unpam.png';
  static const String logoSi = 'assets/images/logo_si_serang.png';
  static const String fotoKtm = 'assets/images/foto_ktm.png';
  static const String ilustrasiDokter = 'assets/images/ilustrasi_dokter.png';
  static const String ilustrasiPasien = 'assets/images/ilustrasi_pasien.png';
}

class AppCredentials {
  static const String namaMahasiswa = 'Mahasiswa';
  static const String nim = 'NIM';
  static const String programStudi = 'Sistem Informasi';
}

class PoliData {
  static const Map<String, String> poliCodes = {
    'Poli Anak': 'A',
    'Poli Mata': 'M',
    'Poli Jantung': 'J',
    'Poli Gigi': 'G',
    'Poli THT': 'T',
    'Poli Kandungan': 'K',
  };

  static const List<String> poliList = [
    'Poli Anak',
    'Poli Mata',
    'Poli Jantung',
    'Poli Gigi',
    'Poli THT',
    'Poli Kandungan',
  ];

  static String getCode(String poliName) => poliCodes[poliName] ?? 'X';
}
