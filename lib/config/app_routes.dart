import 'package:flutter/material.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/queue_registration_page.dart';
import '../pages/queue_list_page.dart';
import '../pages/queue_detail_page.dart';
import '../pages/profile_page.dart';
import '../pages/about_page.dart';
import '../pages/doctor_list_page.dart';
import '../pages/doctor_form_page.dart';
import '../pages/specialist_list_page.dart';
import '../pages/specialist_form_page.dart';
import '../models/doctor.dart';
import '../models/specialist.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String daftar = '/daftar';
  static const String dataAntrean = '/data-antrean';
  static const String detail = '/detail';
  static const String profil = '/profil';
  static const String tentang = '/tentang';
  static const String dokter = '/dokter';
  static const String doctorForm = '/dokter-form';
  static const String spesialis = '/spesialis';
  static const String specialistForm = '/spesialis-form';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case daftar:
        return MaterialPageRoute(
          builder: (_) => const QueueRegistrationPage(),
        );
      case dataAntrean:
        return MaterialPageRoute(builder: (_) => const QueueListPage());
      case detail:
        final queueId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => QueueDetailPage(queueId: queueId),
        );
      case profil:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case tentang:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case dokter:
        return MaterialPageRoute(builder: (_) => const DoctorListPage());
      case doctorForm:
        final doctor = settings.arguments as Doctor?;
        return MaterialPageRoute(
          builder: (_) => DoctorFormPage(doctor: doctor),
        );
      case spesialis:
        return MaterialPageRoute(builder: (_) => const SpecialistListPage());
      case specialistForm:
        final specialist = settings.arguments as Specialist?;
        return MaterialPageRoute(
          builder: (_) => SpecialistFormPage(specialist: specialist),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} tidak ditemukan'),
            ),
          ),
        );
    }
  }
}
