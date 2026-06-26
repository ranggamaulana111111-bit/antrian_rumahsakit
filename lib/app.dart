import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'pages/splash/splash_screen.dart';
import 'pages/login/login_page.dart';
import 'pages/home/home_page.dart';
import 'pages/packing_list/packing_list_page.dart';
import 'pages/detail/packing_item_detail_page.dart';
import 'pages/add_edit/add_edit_packing_item_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/monitor/packing_monitor_page.dart';

class TravelPackApp extends StatelessWidget {
  const TravelPackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return _buildRoute(const SplashScreen(), settings);
      case '/login':
        return _buildRoute(const LoginPage(), settings);
      case '/home':
        return _buildRoute(const HomePage(), settings);
      case '/packing-list':
        return _buildRoute(const PackingListPage(), settings);
      case '/detail':
        final itemId = settings.arguments as int;
        return _buildRoute(PackingItemDetailPage(itemId: itemId), settings);
      case '/add':
        return _buildRoute(const AddEditPackingItemPage(), settings);
      case '/edit':
        final itemId = settings.arguments as int;
        return _buildRoute(AddEditPackingItemPage(itemId: itemId), settings);
      case '/monitor':
        return _buildRoute(const PackingMonitorPage(), settings);
      case '/profile':
        return _buildRoute(const ProfilePage(), settings);
      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeOutCubic;

        var fadeAnimation = Tween<double>(begin: begin, end: end).animate(
          CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
        );

        return FadeTransition(opacity: fadeAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
