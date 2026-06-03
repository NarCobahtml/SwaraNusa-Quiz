import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/providers/firestore_paths.dart';
import 'package:swaranusaquiz/app/data/services/season_service.dart';
import 'package:swaranusaquiz/app/modules/level_selection/models/level_data.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_config.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/quiz_session_page.dart';

class LevelSelectionController {
  static const int unlockScore = 100;

  final String quizTitle;
  final String modeId;
  final Duration transitionDuration;

  const LevelSelectionController({
    required this.quizTitle,
    required this.modeId,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  List<LevelData> get levels {
    return _buildLevels(const {});
  }

  Stream<List<LevelData>> watchLevels({String? seasonId}) {
    final uid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(levels);
    final activeSeasonId =
        seasonId ??
        (Get.isRegistered<SeasonService>()
            ? SeasonService.to.activeSeasonId.value
            : SeasonService.fallbackSeasonId);

    return FirebaseFirestore.instance
        .collection(FirestorePaths.userSeasonLevels(uid, activeSeasonId))
        .snapshots()
        .map((snapshot) {
          final progressByNumber = <int, Map<String, dynamic>>{};
          for (final doc in snapshot.docs) {
            if (!doc.id.startsWith('${modeId}_')) continue;
            final levelNumber = int.tryParse(doc.id.split('_').last);
            if (levelNumber == null) continue;
            progressByNumber[levelNumber] = doc.data();
          }
          return _buildLevels(progressByNumber);
        });
  }

  List<LevelData> _buildLevels(Map<int, Map<String, dynamic>> progressByNumber) {
    final mergedProgress = Map<int, Map<String, dynamic>>.of(progressByNumber);

    return [
      for (var number = 1; number <= 10; number++)
        _levelData(number, mergedProgress),
    ];
  }

  LevelData _levelData(
    int number,
    Map<int, Map<String, dynamic>> progressByNumber,
  ) {
    final progress = progressByNumber[number];
    final isCompleted = progress?['status'] == 'completed';
    final isMarkedUnlocked =
        isCompleted ||
        progress?['status'] == 'unlocked' ||
        _boolValue(progress?['isUnlocked']);
    final isUnlocked =
        number == 1 ||
        isMarkedUnlocked ||
        _scoreForLevel(number - 1, progressByNumber) >= unlockScore;

    return LevelData(
      number: number,
      status: isCompleted ? 'completed' : (isUnlocked ? 'unlocked' : 'locked'),
      stars: _intValue(progress?['stars']),
    );
  }

  int _scoreForLevel(
    int number,
    Map<int, Map<String, dynamic>> progressByNumber,
  ) {
    final progress = progressByNumber[number];
    return _intValue(progress?['bestScore'] ?? progress?['score']);
  }

  int _intValue(Object? value) {
    return value is num ? value.toInt() : 0;
  }

  bool _boolValue(Object? value) {
    return value is bool && value;
  }

  void openLevel(BuildContext context, LevelData level) {
    if (level.isLocked) return;

    Get.to(
      () => QuizSessionPage(
        config: QuizSessionConfig(
          title: quizTitle,
          modeId: modeId,
          levelId: '${modeId}_${level.number}',
        ),
      ),
      transition: Transition.fade,
      duration: transitionDuration,
    );
  }
}
