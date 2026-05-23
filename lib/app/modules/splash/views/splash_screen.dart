import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/splash/controllers/splash_controller.dart';

class SplashScreenSvg extends StatefulWidget {
  const SplashScreenSvg({super.key});

  @override
  State<SplashScreenSvg> createState() => _SplashScreenSvgState();
}

class _SplashScreenSvgState extends State<SplashScreenSvg>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _quizController;
  late AnimationController _titleController;
  late AnimationController _fadeOutController;
  late AnimationController _screenFadeInController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _quizFadeAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _screenFadeOutAnimation;
  late Animation<double> _screenFadeInAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _quizController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _screenFadeInController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _quizFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _quizController, curve: Curves.easeIn));
    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeIn));
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));
    _screenFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut),
    );
    _screenFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _screenFadeInController, curve: Curves.easeIn),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Fade in screen dulu agar transisi dari native splash smooth
    _screenFadeInController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _quizController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) await _fadeOutController.forward();
    if (mounted) {
      Get.find<SplashController>().openNextScreen();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _quizController.dispose();
    _titleController.dispose();
    _fadeOutController.dispose();
    _screenFadeInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _screenFadeInAnimation,
        child: FadeTransition(
          opacity: _screenFadeOutAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          // Hapus placeholderBuilder agar tidak ada kotak hitam/hijau
                          child: SvgPicture.asset(
                            'assets/icon/logo2.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: _quizFadeAnimation,
                          child: const Text(
                            'Quiz',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SlideTransition(
                  position: _titleSlideAnimation,
                  child: FadeTransition(
                    opacity: _titleFadeAnimation,
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Swara',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          TextSpan(
                            text: 'Nusa',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
