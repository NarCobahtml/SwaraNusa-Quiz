import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/season_service.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/controllers/leaderboard_controller.dart';

class LeaderboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SeasonService>()) {
      Get.put<SeasonService>(SeasonService(), permanent: true);
    }
    Get.lazyPut<LeaderboardController>(() => LeaderboardController());
  }
}
