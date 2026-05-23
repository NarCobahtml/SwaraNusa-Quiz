import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/history_quiz/views/sejarah/sejarah_pertanyaan/sejarah_pertanyaan1.dart';
import 'package:swaranusaquiz/app/modules/level_selection/controllers/level_selection_controller.dart';
import 'package:swaranusaquiz/app/modules/level_selection/widgets/level_selection_view.dart';

class LevelSejarah extends StatelessWidget {
  const LevelSejarah({super.key});

  @override
  Widget build(BuildContext context) {
    return const LevelSelectionView(
      title: 'Pilih Level',
      activeIcon: Icons.menu_book,
      controller: LevelSelectionController(
        firstLevelPage: SejarahPertanyaan1(),
      ),
    );
  }
}
