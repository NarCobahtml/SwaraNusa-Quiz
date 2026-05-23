import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/guess_sound/views/tebak/tebak_pertanyaan/tebak_pertanyaan1.dart';
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
        firstLevelPage: TebakPertanyaan1(),
      ),
    );
  }
}
