import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/level_selection/controllers/level_selection_controller.dart';
import 'package:swaranusaquiz/app/modules/level_selection/widgets/level_selection_view.dart';

class LevelTebakSuara extends StatelessWidget {
  const LevelTebakSuara({super.key});

  @override
  Widget build(BuildContext context) {
    return const LevelSelectionView(
      title: 'Pilih Level',
      activeIcon: Icons.headphones,
      controller: LevelSelectionController(
        quizTitle: 'Tebak Suara',
        modeId: 'tebak_suara',
      ),
    );
  }
}
