import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/season_service.dart';
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
              child: Get.isRegistered<SeasonService>()
                  ? Obx(() {
                      return _LevelGrid(
                        seasonId: SeasonService.to.activeSeasonId.value,
                        controller: controller,
                        activeIcon: activeIcon,
                      );
                    })
                  : _LevelGrid(
                      seasonId: SeasonService.fallbackSeasonId,
                      controller: controller,
                      activeIcon: activeIcon,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final String seasonId;
  final LevelSelectionController controller;
  final IconData activeIcon;

  const _LevelGrid({
    required this.seasonId,
    required this.controller,
    required this.activeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LevelData>>(
      key: ValueKey(seasonId),
      stream: controller.watchLevels(seasonId: seasonId),
      initialData: controller.levels,
      builder: (context, snapshot) {
        final levels = snapshot.data ?? controller.levels;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
