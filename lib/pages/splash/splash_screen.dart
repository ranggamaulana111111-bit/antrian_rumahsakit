import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _ringRotate;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _barWidth;
  late final Animation<double> _exitFade;

  late final List<_Orb> _orbs;

  final _random = Random(42);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutQuad),
      ),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _ringRotate = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 2.0, curve: Curves.linear),
      ),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.45, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _barWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.85, curve: Curves.easeInOut),
      ),
    );

    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    _orbs = List.generate(3, (i) => _Orb(index: i, random: _random));

    _controller.forward();

    Timer(const Duration(seconds: AppConstants.splashDurationSeconds), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _exitFade.value,
          child: child,
        );
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  AppColors.primaryDark,
                  AppColors.primary,
                  sin(_controller.value * pi * 0.4) * 0.5 + 0.5,
                )!,
                AppColors.primary,
                Color.lerp(
                  AppColors.primaryLight,
                  AppColors.primary,
                  cos(_controller.value * pi * 0.25) * 0.5 + 0.5,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: [
              ..._buildOrbs(),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogoSection(),
                        const SizedBox(height: 36),
                        _buildTitleSection(),
                        const SizedBox(height: 10),
                        _buildTaglineSection(),
                        const SizedBox(height: 48),
                        _buildProgressBar(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOrbs() {
    return _orbs.map((orb) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final driftX = sin(t * orb.driftSpeed + orb.phase) * orb.rangeX;
          final driftY = cos(t * orb.driftSpeed * 0.7 + orb.phase) * orb.rangeY;
          final x = orb.baseX + driftX;
          final y = orb.baseY + driftY;
          final appear = t < 0.3 ? t / 0.3 : 1.0;

          return Positioned(
            left: x * MediaQuery.of(context).size.width,
            top: y * MediaQuery.of(context).size.height,
            child: Opacity(
              opacity: appear * orb.opacity,
              child: Container(
                width: orb.size,
                height: orb.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: orb.color.withValues(alpha: 0.12),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildLogoSection() {
    return FadeTransition(
      opacity: _logoFade,
      child: ScaleTransition(
        scale: _logoScale,
        child: SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _ringRotate,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(120, 120),
                    painter: _RingPainter(
                      progress: _ringRotate.value,
                      color: AppColors.accent,
                    ),
                  );
                },
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: Image.asset(
                    'assets/images/travel_logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.flight_takeoff_rounded,
                      size: 42,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return FadeTransition(
      opacity: _titleFade,
      child: Text.rich(
        TextSpan(
          children: List.generate(AppConstants.appName.length, (i) {
            return TextSpan(
              text: AppConstants.appName[i],
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.accent,
                letterSpacing: 4.0,
                shadows: [
                  Shadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
            );
          }),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTaglineSection() {
    return SlideTransition(
      position: _taglineSlide,
      child: FadeTransition(
        opacity: _taglineFade,
        child: Text(
          AppConstants.appTagline,
          style: AppTextStyles.bodyText.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 4.0,
            fontWeight: FontWeight.w300,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return FadeTransition(
      opacity: _barWidth,
      child: SizedBox(
        width: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(1),
          child: AnimatedBuilder(
            animation: _barWidth,
            builder: (context, _) {
              return LinearProgressIndicator(
                value: _barWidth.value,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accent.withValues(alpha: 0.6),
                ),
                minHeight: 2,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Orb {
  final int index;
  final double size;
  final double baseX, baseY;
  final double rangeX, rangeY;
  final double driftSpeed;
  final double phase;
  final double opacity;
  final Color color;

  _Orb({required int index, required Random random})
      : index = index,
        size = [200.0, 160.0, 120.0][index],
        baseX = [0.1, 0.7, 0.5][index],
        baseY = [0.15, 0.1, 0.7][index],
        rangeX = [0.08, 0.12, 0.06][index],
        rangeY = [0.06, 0.08, 0.1][index],
        driftSpeed = [0.8, 1.2, 0.5][index],
        phase = random.nextDouble() * pi * 2,
        opacity = [0.6, 0.4, 0.5][index],
        color = [AppColors.accent, AppColors.accentLight, Colors.white][index];
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, paint);

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final sweepAngle = progress * pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      dashPaint,
    );

    final dotAngle = -pi / 2 + sweepAngle;
    final dotX = center.dx + radius * cos(dotAngle);
    final dotY = center.dy + radius * sin(dotAngle);

    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
