import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class AppSnackbar {
  const AppSnackbar._();

  static final ValueNotifier<AppSnackbarMessage?> _message =
      ValueNotifier<AppSnackbarMessage?>(null);
  static Timer? _dismissTimer;

  static void success(String title, String message) {
    _show(
      title,
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  static void error(String title, String message) {
    _show(
      title,
      message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
    );
  }

  static void _show(
    String title,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    _dismissTimer?.cancel();

    _message.value = AppSnackbarMessage(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
    );

    _dismissTimer = Timer(const Duration(seconds: 3), dismiss);
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _message.value = null;
  }
}

class AppSnackbarHost extends StatefulWidget {
  final Widget child;

  const AppSnackbarHost({super.key, required this.child});

  @override
  State<AppSnackbarHost> createState() => _AppSnackbarHostState();
}

class _AppSnackbarHostState extends State<AppSnackbarHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  AppSnackbarMessage? _current;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 320),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    AppSnackbar._message.addListener(_onMessageChanged);
  }

  Future<void> _onMessageChanged() async {
    final msg = AppSnackbar._message.value;

    if (msg != null) {
      // Kalau ada snackbar sebelumnya, dismiss dulu
      if (_controller.value > 0) {
        await _controller.animateBack(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInCubic,
        );
      }
      if (!mounted) return;
      setState(() => _current = msg);
      await _controller.forward(from: 0);
    } else {
      await _controller.animateBack(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInCubic,
      );
      if (mounted) setState(() => _current = null);
    }
  }

  @override
  void dispose() {
    AppSnackbar._message.removeListener(_onMessageChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = math.min(media.size.width * 0.72, 260.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_current != null)
          Positioned(
            top: media.padding.top + 28,
            right: 16,
            width: width,
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _AppSnackbarCard(
                  key: ValueKey<int>(_current!.id),
                  message: _current!,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AppSnackbarCard extends StatelessWidget {
  final AppSnackbarMessage message;

  const _AppSnackbarCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: AppSnackbar.dismiss,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: message.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.overlay.withAlpha(35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(message.icon, color: AppColors.textLight, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.title,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        message.message,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
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

class AppSnackbarMessage {
  final String title;
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final int id;

  AppSnackbarMessage({
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.icon,
  }) : id = DateTime.now().microsecondsSinceEpoch;
}
