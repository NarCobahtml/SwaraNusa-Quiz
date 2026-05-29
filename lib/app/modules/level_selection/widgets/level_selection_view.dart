import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/level_selection/controllers/level_selection_controller.dart';
import 'package:swaranusaquiz/app/modules/level_selection/models/level_data.dart';
import 'package:swaranusaquiz/app/modules/level_selection/widgets/level_card.dart';
import 'package:swaranusaquiz/app/modules/level_selection/widgets/level_header.dart';

class LevelSelectionView extends StatelessWidget {
  final String title;
  final IconData activeIcon;
  final LevelSelectionController controller;

  const LevelSelectionView({
    super.key,
    required this.title,
    required this.activeIcon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            LevelHeader(title: title),
            Expanded(
              child: StreamBuilder<List<LevelData>>(
                stream: controller.watchLevels(),
                initialData: controller.levels,
                builder: (context, snapshot) {
                  final levels = snapshot.data ?? controller.levels;

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 32,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      return LevelCard(
                        level: levels[index],
                        activeIcon: activeIcon,
                        onLevelSelected: (level) {
                          controller.openLevel(context, level);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
