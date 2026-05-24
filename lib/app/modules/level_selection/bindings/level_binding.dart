import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/level_selection/controllers/level_selection_controller.dart';
import 'package:swaranusaquiz/app/routes/app_routes.dart';

class LevelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LevelSelectionController>(() {
      switch (Get.currentRoute) {
        case AppRoutes.levelTebakSuara:
          return const LevelSelectionController(
            quizTitle: 'Tebak Suara',
            modeId: 'tebak_suara',
          );
        case AppRoutes.levelSejarah:
          return const LevelSelectionController(
            quizTitle: 'Sejarah',
            modeId: 'sejarah',
          );
        case AppRoutes.level:
        case AppRoutes.levelTebakGambar:
        default:
          return const LevelSelectionController(
            quizTitle: 'Tebak Gambar',
            modeId: 'tebak_gambar',
          );
      }
    });
  }
}
