import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/level_selection/controllers/level_selection_controller.dart';
import 'package:swaranusaquiz/app/modules/level_selection/widgets/level_selection_view.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/kuis/kuis_pertanyaan/kuis_pertanyaan1.dart';

class LevelSelectionPage extends StatelessWidget {
  final String modeName;
  final String modeKey;

  const LevelSelectionPage({
    super.key,
    this.modeName = 'Tebak Gambar',
    this.modeKey = 'tebak_gambar',
  });

  @override
  Widget build(BuildContext context) {
    return const LevelSelectionView(
      title: 'Select level',
      activeIcon: Icons.graphic_eq,
      controller: LevelSelectionController(
        firstLevelPage: KuisPertanyaan1(),
      ),
    );
  }
}
