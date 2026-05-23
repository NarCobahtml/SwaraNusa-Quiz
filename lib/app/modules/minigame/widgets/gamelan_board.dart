import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class GamelanBoard extends StatelessWidget {
  final int noteCount;
  final int? activePotIndex;
  final ValueChanged<int> onPotPressed;

  const GamelanBoard({
    super.key,
    required this.noteCount,
    required this.activePotIndex,
    required this.onPotPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.divider),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 2, color: AppColors.divider),
                Container(width: 2, color: AppColors.divider),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 30,
              crossAxisSpacing: 30,
              childAspectRatio: 1,
            ),
            itemCount: noteCount,
            itemBuilder: (context, index) {
              return GamelanPot(
                index: index,
                isActive: activePotIndex == index,
                onPressed: () => onPotPressed(index),
              );
            },
          ),
        ],
      ),
    );
  }
}

class GamelanPot extends StatelessWidget {
  final int index;
  final bool isActive;
  final VoidCallback onPressed;

  const GamelanPot({
    super.key,
    required this.index,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.diagonal3Values(
          isActive ? 0.94 : 1.0,
          isActive ? 0.94 : 1.0,
          1,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive
                      ? [AppColors.gold, AppColors.primary]
                      : [AppColors.secondary, AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isActive ? 80 : 40),
                    blurRadius: isActive ? 15 : 6,
                    offset: Offset(0, isActive ? 4 : 2),
                  ),
                  if (isActive)
                    BoxShadow(
                      color: AppColors.gold.withAlpha(80),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
                border: Border.all(
                  color: AppColors.textLight.withAlpha(isActive ? 60 : 30),
                  width: 1.5,
                ),
              ),
            ),
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withAlpha(15),
                border:
                    Border.all(color: Colors.black.withAlpha(30), width: 1),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.2),
                  colors: isActive
                      ? [AppColors.textLight, AppColors.gold]
                      : [AppColors.gold.withAlpha(200), AppColors.success],
                ),
              ),
            ),
            Text(
              '${index + 1}',
              style: TextStyle(
                color: AppColors.textLight
                    .withAlpha(isActive ? 255 : 180),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                shadows: [
                  Shadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
