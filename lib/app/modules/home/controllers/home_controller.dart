import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/backend_models.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/data/services/user_service.dart';
import 'package:swaranusaquiz/app/modules/home/models/home_leaderboard_entry.dart';
import 'package:swaranusaquiz/app/modules/home/models/home_mission.dart';
import 'package:swaranusaquiz/app/modules/home/models/home_profile.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_config.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/quiz_session_page.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';

class HomeController extends GetxController {
  HomeController({ContentRepository? contentRepository})
    : _contentRepository = contentRepository ?? ContentRepository();

  final ContentRepository _contentRepository;
  final leaderboardEntries = <HomeLeaderboardEntry>[].obs;
  final _missionDocs = <MissionDoc>[].obs;
  final _missionProgressById = <String, MissionProgressDoc>{}.obs;
  StreamSubscription<List<HomeLeaderboardEntry>>? _leaderboardSubscription;
  Worker? _userWorker;

  // Baca langsung dari UserService — tidak perlu fetch sendiri
  UserService get _userService => UserService.to;

  @override
  void onInit() {
    super.onInit();
    _watchLeaderboard();
    loadDailyMissions();
    _userWorker = ever(_userService.currentUser, (_) => loadDailyMissions());
  }

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

  List<HomeMission> get dailyMissions {
    return _missionDocs.map((mission) {
      final progress = _missionProgressById[mission.id];
      final target = progress?.target ?? mission.targetValue;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final isStaleDailyProgress =
          mission.type == 'daily' && progress?.dateKey != today;
      final progressValue = isStaleDailyProgress ? 0 : progress?.progress ?? 0;
      return HomeMission(
        iconPath: mission.iconUrl.startsWith('assets/')
            ? mission.iconUrl
            : _iconForMission(mission.targetType),
        title: mission.title,
        progress: progressValue,
        total: target <= 0 ? 1 : target,
        reward: mission.rewardCoin,
        isCompleted: isStaleDailyProgress
            ? false
            : progress?.isCompleted ?? false,
      );
    }).toList(growable: false);
  }

  Future<void> loadDailyMissions() async {
    try {
      final missions = await _contentRepository.loadMissions();
      final uid = auth.FirebaseAuth.instance.currentUser?.uid;
      final progressById = uid == null
          ? const <String, MissionProgressDoc>{}
          : await _contentRepository.loadMissionProgress(uid);
      _missionDocs.assignAll(missions);
      _missionProgressById.assignAll(progressById);
    } catch (_) {
      _missionDocs.clear();
      _missionProgressById.clear();
    }
  }

  String _iconForMission(String targetType) {
    switch (targetType) {
      case 'unlock_instrument':
        return 'assets/image/icon_pelajari.png';
      case 'play_game':
      case 'complete_quiz':
      default:
        return 'assets/image/icon_mainkan.png';
    }
  }

  void _watchLeaderboard() {
    final currentUid = auth.FirebaseAuth.instance.currentUser?.uid;
    _leaderboardSubscription?.cancel();
    _leaderboardSubscription = _contentRepository
        .watchLeaderboard(periodKey: 'global', limit: 3)
        .map(
          (entries) => entries
              .map(
                (entry) => HomeLeaderboardEntry(
                  rank: entry.rank,
                  name: entry.name.isNotEmpty ? entry.name : 'User',
                  xp: entry.xp,
                  avatarPath: entry.avatarUrl.isNotEmpty
                      ? entry.avatarUrl
                      : null,
                  isCurrentUser: entry.uid == currentUid,
                ),
              )
              .toList(growable: false),
        )
        .listen(
          leaderboardEntries.assignAll,
          onError: (_) => leaderboardEntries.clear(),
        );
  }

  void openMode() {
    Get.toNamed(AppRoutes.mode);
  }

  void openDailyQuiz() {
    Get.to(
      () => const QuizSessionPage(config: QuizSessionConfig.dailyQuiz()),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void onClose() {
    _leaderboardSubscription?.cancel();
    _userWorker?.dispose();
    super.onClose();
  }
}
