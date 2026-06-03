import 'dart:async';

import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/leaderboard_user.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/data/services/season_service.dart';

class LeaderboardController extends GetxController {
  LeaderboardController({ContentRepository? contentRepository})
    : _contentRepository = contentRepository ?? ContentRepository();

  final ContentRepository _contentRepository;
  final users = <LeaderboardUser>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final activePeriodKey = SeasonService.fallbackSeasonId.obs;

  StreamSubscription<List<LeaderboardUser>>? _subscription;
  Worker? _seasonWorker;
  int _watchRequestId = 0;

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
    if (Get.isRegistered<SeasonService>()) {
      _seasonWorker = ever(
        SeasonService.to.activeSeasonId,
        (_) => watchLeaderboard(),
      );
    }
  }

  void watchLeaderboard() {
    unawaited(_watchLeaderboard());
  }

  Future<void> _watchLeaderboard() async {
    final requestId = ++_watchRequestId;
    isLoading.value = true;
    errorMessage.value = null;

    final periodKey = await _activeLeaderboardPeriodKey();
    if (periodKey == null) {
      _subscription?.cancel();
      users.clear();
      return;
    }
    if (requestId != _watchRequestId) return;
    activePeriodKey.value = periodKey;

    _subscription?.cancel();
    _subscription = _contentRepository
        .watchLeaderboard(periodKey: periodKey, limit: 50)
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

  Future<String?> _activeLeaderboardPeriodKey() async {
    if (!Get.isRegistered<SeasonService>()) {
      return SeasonService.fallbackSeasonId;
    }

    await SeasonService.to.ensureLoaded();
    final seasonError = SeasonService.to.errorMessage.value;
    if (seasonError != null) {
      errorMessage.value = seasonError;
      isLoading.value = false;
      return null;
    }
    final seasonId = SeasonService.to.activeSeasonId.value.trim();
    return seasonId.isEmpty ? SeasonService.fallbackSeasonId : seasonId;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _seasonWorker?.dispose();
    super.onClose();
  }
}
