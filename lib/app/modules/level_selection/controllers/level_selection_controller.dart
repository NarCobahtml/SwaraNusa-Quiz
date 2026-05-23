import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/level_selection/models/level_data.dart';

class LevelSelectionController {
  final Widget firstLevelPage;
  final Duration transitionDuration;

  const LevelSelectionController({
    required this.firstLevelPage,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  List<LevelData> get levels {
    return const [
      LevelData(number: 1, status: 'completed', stars: 2),
      LevelData(number: 2),
      LevelData(number: 3),
      LevelData(number: 4),
      LevelData(number: 5),
      LevelData(number: 6),
      LevelData(number: 7),
      LevelData(number: 8),
      LevelData(number: 9),
      LevelData(number: 10),
    ];
  }

  void openLevel(BuildContext context, LevelData level) {
    if (level.isLocked || level.number != 1) return;

    Get.to(
      () => firstLevelPage,
      transition: Transition.fade,
      duration: transitionDuration,
    );
  }
}
