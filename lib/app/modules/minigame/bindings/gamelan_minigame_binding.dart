import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/minigame/controllers/gamelan_minigame_controller.dart';

class GamelanMinigameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GamelanMinigameController>(() => GamelanMinigameController());
  }
}
