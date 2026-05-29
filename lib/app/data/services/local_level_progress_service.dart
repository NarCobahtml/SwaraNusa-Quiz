import 'dart:math';

class LocalLevelProgressService {
  LocalLevelProgressService._();

  static final bestScores = <String, int>{};
  static final unlockedLevels = <String>{};
  static final completedLevels = <String>{};

  static void markCompleted({
    required String modeId,
    required String levelId,
    required int score,
  }) {
    final currentBestScore = bestScores[levelId] ?? 0;
    bestScores[levelId] = max(currentBestScore, score);
    unlockedLevels.add(levelId);
    completedLevels.add(levelId);

    final nextLevelId = _nextLevelId(levelId);
    if (nextLevelId != null && bestScores[levelId]! >= 100) {
      unlockedLevels.add(nextLevelId);
      bestScores.putIfAbsent(nextLevelId, () => 0);
    }
  }

  static Map<String, dynamic>? progressFor(String modeId, int levelNumber) {
    final levelId = '${modeId}_$levelNumber';
    if (levelNumber != 1 &&
        !unlockedLevels.contains(levelId) &&
        !completedLevels.contains(levelId) &&
        !bestScores.containsKey(levelId)) {
      return null;
    }

    final isCompleted = completedLevels.contains(levelId);
    final isUnlocked = levelNumber == 1 || unlockedLevels.contains(levelId);

    return {
      'modeId': modeId,
      'levelId': levelId,
      'levelNumber': levelNumber,
      'status': isCompleted
          ? 'completed'
          : (isUnlocked ? 'unlocked' : 'locked'),
      'isUnlocked': isUnlocked,
      'bestScore': bestScores[levelId] ?? 0,
    };
  }

  static String? _nextLevelId(String levelId) {
    final parts = levelId.split('_');
    final number = int.tryParse(parts.last);
    if (number == null || number >= 10) return null;
    return '${parts.take(parts.length - 1).join('_')}_${number + 1}';
  }
}
