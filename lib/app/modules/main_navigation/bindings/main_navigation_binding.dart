import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/user_service.dart';
import 'package:swaranusaquiz/app/modules/home/controllers/home_controller.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/controllers/leaderboard_controller.dart';
import 'package:swaranusaquiz/app/modules/main_navigation/controllers/main_navigation_controller.dart';
import 'package:swaranusaquiz/app/modules/profile/controllers/profile_controller.dart';
import 'package:swaranusaquiz/app/modules/reward/controllers/reward_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    // UserService di-put (bukan lazyPut) agar langsung fetch data user
    Get.put<UserService>(UserService(), permanent: false);
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<LeaderboardController>(() => LeaderboardController.sample());
    Get.lazyPut<RewardController>(() => RewardController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
