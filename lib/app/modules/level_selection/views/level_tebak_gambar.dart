import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/level_selection/controllers/level_selection_controller.dart';
import 'package:swaranusaquiz/app/modules/level_selection/widgets/level_selection_view.dart';

class LevelTebakGambar extends StatelessWidget {
  const LevelTebakGambar({super.key});

  @override
  Widget build(BuildContext context) {
    return const LevelSelectionView(
      title: 'Pilih Level',
      activeIcon: Icons.image,
      controller: LevelSelectionController(
        quizTitle: 'Tebak Gambar',
        modeId: 'tebak_gambar',
        transitionDuration: Duration(milliseconds: 150),
      ),
    );
  }
}
