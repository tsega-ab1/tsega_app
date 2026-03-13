import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../services/storage_service.dart';
import '../../core/providers/language_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _pulse;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));

    _fade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);
    _scale = Tween(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _pulse = Tween(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _logoCtrl.forward();
    _progressCtrl.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _pulseCtrl.repeat(reverse: true);
    });

    Future.delayed(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final isFirst = StorageService.isFirstLaunch;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isFirst ? const OnboardingScreen() : const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: TGradients.gradTeal),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        // Pulsing logo
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) => Transform.scale(
                            scale: _pulse.value,
                            child: Container(
                              width: 130, height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: TColors.white.withOpacity(0.15),
                                border: Border.all(
                                    color: TColors.white.withOpacity(0.5),
                                    width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: TColors.white.withOpacity(0.2),
                                    blurRadius: 30, spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Text('ጸጋ',
                                    style: TextStyle(fontSize: 54,
                                        color: TColors.white,
                                        fontWeight: FontWeight.w300)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text('TSEGA',
                            style: TextStyle(fontSize: 38,
                                color: TColors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 8)),
                        const SizedBox(height: 10),
                        Text('Precision Health for Every Woman',
                            style: TextStyle(fontSize: 14,
                                color: TColors.white.withOpacity(0.85),
                                letterSpacing: 1.5)),
                      ]),
                    ),
                  ),
                ),
              ),
              // Progress bar
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 48),
                child: Column(children: [
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        backgroundColor: TColors.white.withOpacity(0.2),
                        color: TColors.white,
                        minHeight: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Loading your health companion...',
                      style: TextStyle(fontSize: 12,
                          color: TColors.white.withOpacity(0.6))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
