import 'dart:async';

import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/leaderboard_user.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';

class LeaderboardController extends GetxController {
  LeaderboardController({ContentRepository? contentRepository})
    : _contentRepository = contentRepository ?? ContentRepository();

  final ContentRepository _contentRepository;
  final users = <LeaderboardUser>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<LeaderboardUser>>? _subscription;

  List<LeaderboardUser> get topUsers {
    return users.length >= 3 ? users.sublist(0, 3) : users.toList();
  }

  List<LeaderboardUser> get remainingUsers {
    return users.length > 3 ? users.sublist(3) : const <LeaderboardUser>[];
  }

  @override
  void onInit() {
    super.onInit();
    watchLeaderboard();
  }

  void watchLeaderboard() {
    isLoading.value = true;
    errorMessage.value = null;
    _subscription?.cancel();
    _subscription = _contentRepository
        .watchLeaderboard(periodKey: 'global', limit: 50)
        .map((entries) => entries.map(LeaderboardUser.fromDoc).toList())
        .listen(
          (leaderboardUsers) {
            users.assignAll(leaderboardUsers);
            isLoading.value = false;
          },
          onError: (Object error) {
            errorMessage.value = 'Gagal memuat leaderboard.';
            isLoading.value = false;
          },
        );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
