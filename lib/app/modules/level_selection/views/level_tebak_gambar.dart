import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/level_selection/controllers/level_selection_controller.dart';
import 'package:swaranusaquiz/app/modules/level_selection/widgets/level_selection_view.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/kuis/kuis_pertanyaan/kuis_pertanyaan1.dart';

class LevelTebakGambar extends StatelessWidget {
  const LevelTebakGambar({super.key});

  @override
  Widget build(BuildContext context) {
    return const LevelSelectionView(
      title: 'Pilih Level',
      activeIcon: Icons.image,
      controller: LevelSelectionController(
        firstLevelPage: KuisPertanyaan1(),
        transitionDuration: Duration(milliseconds: 150),
      ),
    );
  }
}
