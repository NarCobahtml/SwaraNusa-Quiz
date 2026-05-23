import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/leaderboard_user.dart';

class LeaderboardController extends GetxController {
  final List<LeaderboardUser> users;

  LeaderboardController(this.users);

  factory LeaderboardController.sample() {
    return LeaderboardController(LeaderboardData.getSampleData());
  }

  List<LeaderboardUser> get topUsers {
    return users.length >= 3 ? users.sublist(0, 3) : users;
  }

  List<LeaderboardUser> get remainingUsers {
    return users.length > 3 ? users.sublist(3) : const <LeaderboardUser>[];
  }
}
