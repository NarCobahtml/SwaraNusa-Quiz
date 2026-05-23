import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/level_selection/models/level_data.dart';

class LevelCard extends StatefulWidget {
  final LevelData level;
  final IconData activeIcon;
  final ValueChanged<LevelData> onLevelSelected;

  const LevelCard({
    super.key,
    required this.level,
    required this.activeIcon,
    required this.onLevelSelected,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.level.isLocked) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.level.isLocked) {
      _controller.reverse();
      widget.onLevelSelected(widget.level);
    }
  }

  void _onTapCancel() {
    if (!widget.level.isLocked) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: widget.level.isLocked
                  ? const _LockedLevelCard()
                  : _ActiveLevelCard(icon: widget.activeIcon),
            ),
            const SizedBox(height: 12),
            Text(
              'LEVEL ${widget.level.number.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: widget.level.isLocked
                    ? AppColors.textMuted.withAlpha(100)
                    : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveLevelCard extends StatelessWidget {
  final IconData icon;

  const _ActiveLevelCard({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
            color: AppColors.textLight.withAlpha(40), width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.textLight.withAlpha(50), width: 3),
            color: AppColors.textLight.withAlpha(20),
          ),
          child: Icon(icon, color: AppColors.textLight, size: 32),
        ),
      ),
    );
  }
}

class _LockedLevelCard extends StatelessWidget {
  const _LockedLevelCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: const Center(
        child: Icon(Icons.lock, color: AppColors.textMuted, size: 30),
      ),
    );
  }
}
