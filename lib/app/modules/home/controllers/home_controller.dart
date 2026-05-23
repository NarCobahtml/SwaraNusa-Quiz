import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/user_service.dart';
import 'package:swaranusaquiz/app/modules/home/models/home_leaderboard_entry.dart';
import 'package:swaranusaquiz/app/modules/home/models/home_mission.dart';
import 'package:swaranusaquiz/app/modules/home/models/home_profile.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';

class HomeController extends GetxController {
  // Baca langsung dari UserService — tidak perlu fetch sendiri
  UserService get _userService => UserService.to;

  HomeProfile get profile {
    final user = _userService.currentUser.value;
    if (user == null) {
      return const HomeProfile(
        name: '...',
        level: 1,
        xp: 0,
        avatarPath: 'assets/image/user_profile.png',
      );
    }
    return HomeProfile(
      name: user.name.isNotEmpty ? user.name : user.username,
      level: user.level,
      xp: user.xp,
      avatarPath: user.avatarUrl.isNotEmpty
          ? user.avatarUrl
          : 'assets/image/user_profile.png',
    );
  }

  List<HomeMission> get dailyMissions => const [];

  List<HomeLeaderboardEntry> get leaderboardEntries => const [];

  void openMode() {
    Get.toNamed(AppRoutes.mode);
  }
}
