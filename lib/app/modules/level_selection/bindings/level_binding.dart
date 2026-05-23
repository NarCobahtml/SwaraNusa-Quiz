import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/guess_sound/views/tebak/tebak_pertanyaan/tebak_pertanyaan1.dart';
import 'package:swaranusaquiz/app/modules/history_quiz/views/sejarah/sejarah_pertanyaan/sejarah_pertanyaan1.dart';
import 'package:swaranusaquiz/app/modules/level_selection/controllers/level_selection_controller.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/kuis/kuis_pertanyaan/kuis_pertanyaan1.dart';
import 'package:swaranusaquiz/app/routes/app_routes.dart';

class LevelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LevelSelectionController>(() {
      switch (Get.currentRoute) {
        case AppRoutes.levelTebakSuara:
          return const LevelSelectionController(
            firstLevelPage: TebakPertanyaan1(),
          );
        case AppRoutes.levelSejarah:
          return const LevelSelectionController(
            firstLevelPage: SejarahPertanyaan1(),
          );
        case AppRoutes.level:
        case AppRoutes.levelTebakGambar:
        default:
          return const LevelSelectionController(
            firstLevelPage: KuisPertanyaan1(),
          );
      }
    });
  }
}
