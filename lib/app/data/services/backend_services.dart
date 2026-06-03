import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:swaranusaquiz/app/data/providers/backend_bootstrap.dart';
import 'package:swaranusaquiz/app/data/providers/firestore_paths.dart';
import 'package:swaranusaquiz/app/data/services/local_level_progress_service.dart';

int _numberValue(Object? value) => value is num ? value.toInt() : 0;

String _textValue(Object? value) => value?.toString() ?? '';

String _firstNonEmptyText(List<Object?> values) {
  for (final value in values) {
    final text = _textValue(value).trim();
    if (text.isNotEmpty) return text;
  }
  return 'User';
}

String _todayKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

Map<String, Object?> _leaderboardData(
  Map<String, dynamic> userData, {
  required int xp,
  required int level,
  required int quizCompleted,
}) {
  return {
    'periodType': 'global',
    'periodKey': 'global',
    'name': _firstNonEmptyText([
      userData['name'],
      userData['username'],
      userData['email'],
      'User',
    ]),
    'username': _textValue(userData['username']),
    'avatarUrl': _textValue(userData['avatarUrl']),
    'level': level,
    'xp': xp,
    'score': xp,
    'quizCompleted': quizCompleted,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class QuizAnswerRecord {
  final String questionId;
  final int questionNumber;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String mediaUrl;
  final String mediaType;
  final int timeSpentSeconds;
  final int pointsEarned;

  const QuizAnswerRecord({
    required this.questionId,
    required this.questionNumber,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.mediaUrl = '',
    this.mediaType = '',
    required this.timeSpentSeconds,
    required this.pointsEarned,
  });

  Map<String, Object?> toMap() => {
    'questionId': questionId,
    'questionNumber': questionNumber,
    'userAnswer': userAnswer,
    'correctAnswer': correctAnswer,
    'isCorrect': isCorrect,
    'mediaUrl': mediaUrl,
    'mediaType': mediaType,
    'timeSpentSeconds': timeSpentSeconds,
    'pointsEarned': pointsEarned,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class QuizSessionSummary {
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final int score;
  final int earnedXp;
  final int earnedCoin;
  final int bonusCoin;
  final int perfectRewardCoin;
  final bool isDailyQuiz;
  final bool rewardAlreadyClaimed;

  const QuizSessionSummary({
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    required this.score,
    this.earnedXp = 0,
    this.earnedCoin = 0,
    this.bonusCoin = 0,
    this.perfectRewardCoin = 0,
    this.isDailyQuiz = false,
    this.rewardAlreadyClaimed = false,
  });

  QuizSessionSummary copyWith({
    int? correctAnswers,
    int? wrongAnswers,
    int? totalQuestions,
    int? score,
    int? earnedXp,
    int? earnedCoin,
    int? bonusCoin,
    int? perfectRewardCoin,
    bool? isDailyQuiz,
    bool? rewardAlreadyClaimed,
  }) {
    return QuizSessionSummary(
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      score: score ?? this.score,
      earnedXp: earnedXp ?? this.earnedXp,
      earnedCoin: earnedCoin ?? this.earnedCoin,
      bonusCoin: bonusCoin ?? this.bonusCoin,
      perfectRewardCoin: perfectRewardCoin ?? this.perfectRewardCoin,
      isDailyQuiz: isDailyQuiz ?? this.isDailyQuiz,
      rewardAlreadyClaimed:
          rewardAlreadyClaimed ?? this.rewardAlreadyClaimed,
    );
  }
}

class _DailyQuizSaveResult {
  final int bonusCoin;
  final bool rewardAlreadyClaimed;

  const _DailyQuizSaveResult({
    required this.bonusCoin,
    required this.rewardAlreadyClaimed,
  });
}

class QuizEngineService {
  QuizEngineService({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  static final QuizEngineService instance = QuizEngineService();

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;
  final List<QuizAnswerRecord> _answers = [];
  DateTime? _startedAt;
  String _modeId = 'tebak_gambar';
  String _levelId = 'tebak_gambar_1';
  int _totalQuestions = 10;
  bool _isDailyQuiz = false;
  int _dailyPerfectRewardCoin = 100;
  String _dailyDateKey = '';
  bool _isFinished = false;
  QuizSessionSummary? _lastSummary;

  QuizSessionSummary? get lastSummary => _lastSummary;
  List<QuizAnswerRecord> get answers => List.unmodifiable(_answers);

  void start({
    String modeId = 'tebak_gambar',
    String levelId = 'tebak_gambar_1',
    int totalQuestions = 10,
    bool isDailyQuiz = false,
    int dailyPerfectRewardCoin = 100,
  }) {
    _answers.clear();
    _startedAt = DateTime.now();
    _modeId = modeId;
    _levelId = levelId;
    _totalQuestions = totalQuestions;
    _isDailyQuiz = isDailyQuiz;
    _dailyPerfectRewardCoin = dailyPerfectRewardCoin;
    _dailyDateKey = _todayKey();
    _isFinished = false;
    _lastSummary = null;
  }

  bool checkAnswer({
    required String questionId,
    required int questionNumber,
    required String selectedAnswer,
    required String correctAnswer,
    int points = 10,
    int timeSpentSeconds = 0,
    String mediaUrl = '',
    String mediaType = '',
  }) {
    if (_startedAt == null) {
      start(
        modeId: _modeId,
        levelId: _levelId,
        totalQuestions: _totalQuestions,
        isDailyQuiz: _isDailyQuiz,
        dailyPerfectRewardCoin: _dailyPerfectRewardCoin,
      );
    }
    final question = BackendBootstrap.instance.questionsById[questionId];
    final authoritativeCorrectAnswer = question?.correctAnswer ?? correctAnswer;
    final authoritativePoints = question?.points ?? points;
    final isCorrect =
        selectedAnswer.trim().toLowerCase() ==
        authoritativeCorrectAnswer.trim().toLowerCase();
    _answers.removeWhere((answer) => answer.questionNumber == questionNumber);
    _answers.add(
      QuizAnswerRecord(
        questionId: questionId,
        questionNumber: questionNumber,
        userAnswer: selectedAnswer,
        correctAnswer: authoritativeCorrectAnswer,
        isCorrect: isCorrect,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        timeSpentSeconds: timeSpentSeconds,
        pointsEarned: isCorrect ? authoritativePoints : 0,
      ),
    );
    _answers.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    return isCorrect;
  }

  QuizSessionSummary currentSummary() {
    final correct = _answers.where((answer) => answer.isCorrect).length;
    final wrong = max(0, _totalQuestions - correct);
    final score = _totalQuestions == 0
        ? 0
        : ((correct / _totalQuestions) * 100).round();
    return QuizSessionSummary(
      correctAnswers: correct,
      wrongAnswers: wrong,
      totalQuestions: _totalQuestions,
      score: score,
      perfectRewardCoin: _isDailyQuiz ? _dailyPerfectRewardCoin : 0,
      isDailyQuiz: _isDailyQuiz,
    );
  }

  Future<QuizSessionSummary> finish() async {
    if (_isFinished) return _lastSummary ?? currentSummary();
    var summary = currentSummary();

    if (!_isDailyQuiz) {
      LocalLevelProgressService.markCompleted(
        modeId: _modeId,
        levelId: _levelId,
        score: summary.score,
      );
    }

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('Hasil kuis tidak disimpan: FirebaseAuth currentUser null.');
      _isFinished = true;
      _lastSummary = summary;
      return summary;
    }
    debugPrint(
      'Menyimpan hasil kuis untuk uid=${user.uid}, '
      'score=${summary.score}, benar=${summary.correctAnswers}, '
      'salah=${summary.wrongAnswers}.',
    );

    final startedAt = _startedAt ?? DateTime.now();
    final durationSeconds = DateTime.now().difference(startedAt).inSeconds;
    final earnedXp = _isDailyQuiz ? 0 : summary.correctAnswers * 15;
    final earnedCoin = _isDailyQuiz ? 0 : summary.correctAnswers * 5;

    final userRef = _firestore.doc(FirestorePaths.user(user.uid));
    if (_isDailyQuiz) {
      final reward = await _saveDailyQuizProgress(
        userRef: userRef,
        uid: user.uid,
        summary: summary,
        earnedXp: earnedXp,
      );
      summary = summary.copyWith(
        earnedXp: earnedXp,
        earnedCoin: earnedCoin,
        bonusCoin: reward.bonusCoin,
        rewardAlreadyClaimed: reward.rewardAlreadyClaimed,
      );
    } else {
      final levelProgressRef = _firestore.doc(
        FirestorePaths.userLevelProgress(user.uid, _levelId),
      );
      final nextLevel = _nextLevelId(_levelId);
      final nextLevelRef = nextLevel == null
          ? null
          : _firestore.doc(
              FirestorePaths.userLevelProgress(user.uid, nextLevel),
            );
      await _saveRequiredQuizProgress(
        userRef: userRef,
        levelProgressRef: levelProgressRef,
        nextLevelRef: nextLevelRef,
        nextLevel: nextLevel,
        uid: user.uid,
        summary: summary,
        earnedXp: earnedXp,
        earnedCoin: earnedCoin,
      );
      summary = summary.copyWith(earnedXp: earnedXp, earnedCoin: earnedCoin);
    }

    _isFinished = true;
    _lastSummary = summary;

    try {
      await _saveOptionalQuizRecords(
        user: user,
        startedAt: startedAt,
        durationSeconds: durationSeconds,
        earnedXp: earnedXp,
        earnedCoin: earnedCoin + summary.bonusCoin,
        summary: summary,
      );
      await MissionService.instance.incrementProgress('complete_quiz', by: 1);
      await BadgeService.instance.checkAndAwardBadges();
    } catch (error) {
      debugPrint('Gagal menyimpan data tambahan kuis: $error');
    }

    return summary;
  }

  Future<void> _saveRequiredQuizProgress({
    required DocumentReference<Map<String, dynamic>> userRef,
    required DocumentReference<Map<String, dynamic>> levelProgressRef,
    required DocumentReference<Map<String, dynamic>>? nextLevelRef,
    required String? nextLevel,
    required String uid,
    required QuizSessionSummary summary,
    required int earnedXp,
    required int earnedCoin,
  }) async {
    final stars = _starsForScore(summary.score);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final userData = userSnapshot.data() ?? {};
      final nextXp = _numberValue(userData['xp']) + earnedXp;
      final nextCoin = _numberValue(userData['coin']) + earnedCoin;
      final nextLevel = max(1, (nextXp / 500).floor() + 1);
      final nextQuizCompleted = _numberValue(userData['quizCompleted']) + 1;
      final nextCorrectCount =
          _numberValue(userData['correctAnswerCount']) +
          summary.correctAnswers;
      final nextWrongCount =
          _numberValue(userData['wrongAnswerCount']) + summary.wrongAnswers;
      final nextPerfectScoreCount =
          _numberValue(userData['perfectScoreCount']) +
          (summary.score >= 100 ? 1 : 0);

      transaction.set(userRef, {
        'xp': nextXp,
        'coin': nextCoin,
        'level': nextLevel,
        'quizCompleted': nextQuizCompleted,
        'correctAnswerCount': nextCorrectCount,
        'wrongAnswerCount': nextWrongCount,
        'perfectScoreCount': nextPerfectScoreCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(
        _firestore.doc(FirestorePaths.leaderboardEntry('global', uid)),
        _leaderboardData(
          userData,
          xp: nextXp,
          level: nextLevel,
          quizCompleted: nextQuizCompleted,
        ),
        SetOptions(merge: true),
      );
    });
    debugPrint('Statistik user berhasil disimpan ke ${userRef.path}.');

    try {
      final batch = _firestore.batch();
      batch.set(levelProgressRef, {
        'modeId': _modeId,
        'levelId': _levelId,
        'levelNumber': _levelNumberFromId(_levelId),
        'status': 'completed',
        'isUnlocked': true,
        'stars': stars,
        'score': summary.score,
        'bestScore': summary.score,
        'bestCorrectAnswers': summary.correctAnswers,
        'attemptCount': FieldValue.increment(1),
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (nextLevel != null && nextLevelRef != null && summary.score >= 100) {
        batch.set(nextLevelRef, {
          'modeId': _modeId,
          'levelId': nextLevel,
          'levelNumber': _levelNumberFromId(nextLevel),
          'status': 'unlocked',
          'isUnlocked': true,
          'stars': 0,
          'score': 0,
          'bestScore': 0,
          'bestCorrectAnswers': 0,
          'attemptCount': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (error) {
      debugPrint('Gagal menyimpan progress level: $error');
    }
  }

  Future<_DailyQuizSaveResult> _saveDailyQuizProgress({
    required DocumentReference<Map<String, dynamic>> userRef,
    required String uid,
    required QuizSessionSummary summary,
    required int earnedXp,
  }) {
    final dateKey = _dailyDateKey.isEmpty ? _todayKey() : _dailyDateKey;
    final dailyQuizRef = _firestore.doc(
      FirestorePaths.userDailyQuiz(uid, dateKey),
    );

    return _firestore.runTransaction<_DailyQuizSaveResult>((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final dailySnapshot = await transaction.get(dailyQuizRef);
      final userData = userSnapshot.data() ?? {};
      final dailyData = dailySnapshot.data() ?? {};

      final alreadyClaimed = dailyData['rewardClaimed'] == true;
      final shouldAwardBonus = summary.score >= 100 && !alreadyClaimed;
      final bonusCoin = shouldAwardBonus ? _dailyPerfectRewardCoin : 0;
      final nextXp = _numberValue(userData['xp']) + earnedXp;
      final nextCoin = _numberValue(userData['coin']) + bonusCoin;
      final nextLevel = max(1, (nextXp / 500).floor() + 1);
      final nextQuizCompleted = _numberValue(userData['quizCompleted']) + 1;
      final nextCorrectCount =
          _numberValue(userData['correctAnswerCount']) +
          summary.correctAnswers;
      final nextWrongCount =
          _numberValue(userData['wrongAnswerCount']) + summary.wrongAnswers;
      final nextPerfectScoreCount =
          _numberValue(userData['perfectScoreCount']) +
          (shouldAwardBonus ? 1 : 0);

      transaction.set(userRef, {
        'xp': nextXp,
        'coin': nextCoin,
        'level': nextLevel,
        'quizCompleted': nextQuizCompleted,
        'correctAnswerCount': nextCorrectCount,
        'wrongAnswerCount': nextWrongCount,
        'perfectScoreCount': nextPerfectScoreCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(
        _firestore.doc(FirestorePaths.leaderboardEntry('global', uid)),
        _leaderboardData(
          userData,
          xp: nextXp,
          level: nextLevel,
          quizCompleted: nextQuizCompleted,
        ),
        SetOptions(merge: true),
      );

      transaction.set(dailyQuizRef, {
        'dateKey': dateKey,
        'modeId': _modeId,
        'levelId': _levelId,
        'attemptCount': FieldValue.increment(1),
        'lastScore': summary.score,
        'bestScore': max(_numberValue(dailyData['bestScore']), summary.score),
        'lastCorrectAnswers': summary.correctAnswers,
        'bestCorrectAnswers': max(
          _numberValue(dailyData['bestCorrectAnswers']),
          summary.correctAnswers,
        ),
        'totalQuestions': summary.totalQuestions,
        'rewardCoin': _dailyPerfectRewardCoin,
        'rewardClaimed': alreadyClaimed || shouldAwardBonus,
        'lastCompletedAt': FieldValue.serverTimestamp(),
        if (shouldAwardBonus) 'rewardedAt': FieldValue.serverTimestamp(),
        if (!dailySnapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return _DailyQuizSaveResult(
        bonusCoin: bonusCoin,
        rewardAlreadyClaimed: alreadyClaimed && summary.score >= 100,
      );
    });
  }

  Future<void> _saveOptionalQuizRecords({
    required auth.User user,
    required DateTime startedAt,
    required int durationSeconds,
    required int earnedXp,
    required int earnedCoin,
    required QuizSessionSummary summary,
  }) async {
    final attemptId = _firestore.collection('_ids').doc().id;
    final attemptRef = _firestore.doc(
      FirestorePaths.userQuizAttempt(user.uid, attemptId),
    );

    final batch = _firestore.batch();

    batch.set(attemptRef, {
      'sessionType': _isDailyQuiz ? 'daily' : 'level',
      'modeId': _modeId,
      'levelId': _levelId,
      'totalQuestions': summary.totalQuestions,
      'correctAnswers': summary.correctAnswers,
      'wrongAnswers': summary.wrongAnswers,
      'score': summary.score,
      'earnedXp': earnedXp,
      'earnedCoin': earnedCoin,
      'bonusCoin': summary.bonusCoin,
      'durationSeconds': durationSeconds,
      'startedAt': Timestamp.fromDate(startedAt),
      'finishedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (final answer in _answers) {
      batch.set(
        _firestore.doc(
          FirestorePaths.userQuizAttemptAnswer(
            user.uid,
            attemptId,
            'q${answer.questionNumber}',
          ),
        ),
        answer.toMap(),
      );
    }

    await batch.commit();
  }

  int _starsForScore(int score) {
    if (score >= 90) return 3;
    if (score >= 70) return 2;
    if (score > 0) return 1;
    return 0;
  }

  String? _nextLevelId(String levelId) {
    final parts = levelId.split('_');
    final number = int.tryParse(parts.last);
    if (number == null || number >= 10) return null;
    return '${parts.take(parts.length - 1).join('_')}_${number + 1}';
  }

  int _levelNumberFromId(String levelId) {
    final parts = levelId.split('_');
    return int.tryParse(parts.last) ?? 1;
  }
}

class LeaderboardSyncService {
  LeaderboardSyncService({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  static final LeaderboardSyncService instance = LeaderboardSyncService();

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  Future<void> syncCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await syncUser(user.uid);
  }

  Future<void> syncUser(String uid) async {
    final userSnapshot = await _firestore.doc(FirestorePaths.user(uid)).get();
    if (!userSnapshot.exists) return;

    final data = userSnapshot.data() ?? {};
    final xp = _intValue(data['xp']);
    final name = _firstNonEmpty([
      data['name'],
      data['username'],
      data['email'],
      'User',
    ]);

    await _firestore.doc(FirestorePaths.leaderboardEntry('global', uid)).set({
      'periodType': 'global',
      'periodKey': 'global',
      'name': name,
      'username': _stringValue(data['username']),
      'avatarUrl': _stringValue(data['avatarUrl']),
      'level': _intValue(data['level']),
      'xp': xp,
      'score': xp,
      'quizCompleted': _intValue(data['quizCompleted']),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  int _intValue(Object? value) => value is num ? value.toInt() : 0;

  String _stringValue(Object? value) => value?.toString() ?? '';

  String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final text = _stringValue(value).trim();
      if (text.isNotEmpty) return text;
    }
    return 'User';
  }
}

class MissionService {
  MissionService({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  static final MissionService instance = MissionService();

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  Future<void> incrementProgress(String targetType, {int by = 1}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final missions = await _firestore
        .collection(FirestorePaths.missions)
        .where('targetType', isEqualTo: targetType)
        .where('isActive', isEqualTo: true)
        .get();
    if (missions.docs.isEmpty) return;

    await _firestore.runTransaction((transaction) async {
      final progressRefs = [
        for (final mission in missions.docs)
          _firestore.doc(
            FirestorePaths.userMissionProgress(user.uid, mission.id),
          ),
      ];
      final progressSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final progressRef in progressRefs) {
        progressSnapshots.add(await transaction.get(progressRef));
      }

      for (var i = 0; i < missions.docs.length; i++) {
        final mission = missions.docs[i];
        final progressRef = progressRefs[i];
        final progressData = progressSnapshots[i].data() ?? {};
        final data = mission.data();
        final target = (data['targetValue'] as num?)?.toInt() ?? 0;
        final isDaily = data['type']?.toString() == 'daily';
        final shouldReset =
            isDaily && progressData['dateKey']?.toString() != today;
        final current = shouldReset
            ? 0
            : (progressData['progress'] as num?)?.toInt() ?? 0;
        final next = min(target, current + by);
        transaction.set(progressRef, {
          'progress': next,
          'target': target,
          'isCompleted': target > 0 && next >= target,
          'isClaimed': shouldReset ? false : progressData['isClaimed'] == true,
          'dateKey': isDaily ? today : progressData['dateKey']?.toString() ?? '',
          'completedAt': target > 0 && next >= target
              ? FieldValue.serverTimestamp()
              : shouldReset
              ? null
              : progressData['completedAt'],
          'claimedAt': shouldReset ? null : progressData['claimedAt'],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> claimMission(String missionId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final missionRef = _firestore.doc('${FirestorePaths.missions}/$missionId');
    final progressRef = _firestore.doc(
      FirestorePaths.userMissionProgress(user.uid, missionId),
    );
    final userRef = _firestore.doc(FirestorePaths.user(user.uid));
    final leaderboardRef = _firestore.doc(
      FirestorePaths.leaderboardEntry('global', user.uid),
    );
    final unlockedNewInstrument = await _firestore.runTransaction<bool>((
      transaction,
    ) async {
      final mission = await transaction.get(missionRef);
      final progress = await transaction.get(progressRef);
      final userSnapshot = await transaction.get(userRef);
      if (!mission.exists || !progress.exists) return false;
      if (!userSnapshot.exists) return false;
      final missionData = mission.data() as Map<String, dynamic>;
      final progressData = progress.data() as Map<String, dynamic>;
      final userData = userSnapshot.data() ?? {};
      if (progressData['isCompleted'] != true ||
          progressData['isClaimed'] == true) {
        return false;
      }
      final isDaily = missionData['type']?.toString() == 'daily';
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (isDaily && progressData['dateKey']?.toString() != today) {
        return false;
      }
      final rewardXp = (missionData['rewardXp'] as num?)?.toInt() ?? 0;
      final rewardCoin = (missionData['rewardCoin'] as num?)?.toInt() ?? 0;
      final rewardInstrumentId =
          missionData['rewardInstrumentId']?.toString() ?? '';
      DocumentSnapshot<Map<String, dynamic>>? ownershipSnapshot;
      if (rewardInstrumentId.isNotEmpty) {
        ownershipSnapshot = await transaction.get(
          _firestore.doc(
            FirestorePaths.userInstrument(user.uid, rewardInstrumentId),
          ),
        );
      }
      final nextXp = _numberValue(userData['xp']) + rewardXp;
      final nextCoin = _numberValue(userData['coin']) + rewardCoin;
      final nextLevel = max(1, (nextXp / 500).floor() + 1);
      final quizCompleted = _numberValue(userData['quizCompleted']);
      final isNewInstrument =
          rewardInstrumentId.isNotEmpty &&
          (ownershipSnapshot == null ||
              ownershipSnapshot.data()?['isUnlocked'] != true);
      final nextOwnedInstrumentCount =
          _numberValue(userData['ownedInstrumentCount']) +
          (isNewInstrument ? 1 : 0);

      transaction.set(progressRef, {
        'isClaimed': true,
        'claimedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(userRef, {
        'xp': nextXp,
        'coin': nextCoin,
        'level': nextLevel,
        'ownedInstrumentCount': nextOwnedInstrumentCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(
        leaderboardRef,
        _leaderboardData(
          userData,
          xp: nextXp,
          level: nextLevel,
          quizCompleted: quizCompleted,
        ),
        SetOptions(merge: true),
      );
      if (rewardInstrumentId.isNotEmpty) {
        transaction.set(
          _firestore.doc(
            FirestorePaths.userInstrument(user.uid, rewardInstrumentId),
          ),
          {
            'isUnlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
            'source': 'mission_reward',
          },
          SetOptions(merge: true),
        );
      }
      return isNewInstrument;
    });
    if (unlockedNewInstrument) {
      await MissionService.instance.incrementProgress(
        'unlock_instrument',
        by: 1,
      );
    }
    await BadgeService.instance.checkAndAwardBadges();
  }
}

class RewardService {
  RewardService({FirebaseFirestore? firestore, auth.FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  static final RewardService instance = RewardService();

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  Future<void> purchaseInstrument(String instrumentId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final instrumentRef = _firestore.doc(
      '${FirestorePaths.instruments}/$instrumentId',
    );
    final ownershipRef = _firestore.doc(
      FirestorePaths.userInstrument(user.uid, instrumentId),
    );
    final userRef = _firestore.doc(FirestorePaths.user(user.uid));

    final purchased = await _firestore.runTransaction<bool>((transaction) async {
      final instrument = await transaction.get(instrumentRef);
      final ownership = await transaction.get(ownershipRef);
      final userSnapshot = await transaction.get(userRef);
      if (!instrument.exists || !userSnapshot.exists) return false;
      final owned =
          ownership.exists && (ownership.data()?['isUnlocked'] == true);
      if (owned) return false;
      final instrumentData = instrument.data()!;
      final userData = userSnapshot.data()!;
      final price = (instrumentData['price'] as num?)?.toInt() ?? 0;
      final coin = (userData['coin'] as num?)?.toInt() ?? 0;
      if (coin < price) {
        throw StateError('Coin tidak cukup');
      }
      transaction.set(userRef, {
        'coin': coin - price,
        'ownedInstrumentCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(ownershipRef, {
        'isUnlocked': true,
        'unlockedAt': FieldValue.serverTimestamp(),
        'source': 'coin_purchase',
      }, SetOptions(merge: true));
      return true;
    });
    if (!purchased) return;

    try {
      await MissionService.instance.incrementProgress(
        'unlock_instrument',
        by: 1,
      );
      await BadgeService.instance.checkAndAwardBadges();
      await LeaderboardSyncService.instance.syncUser(user.uid);
    } catch (error) {
      debugPrint('Gagal menyimpan data tambahan reward: $error');
    }
  }

  Future<void> claimDailyLogin() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final loginRef = _firestore.doc(FirestorePaths.userDailyLogin(user.uid));
    final userRef = _firestore.doc(FirestorePaths.user(user.uid));
    final leaderboardRef = _firestore.doc(
      FirestorePaths.leaderboardEntry('global', user.uid),
    );

    final unlockedNewInstrument = await _firestore.runTransaction<bool>((
      transaction,
    ) async {
      final login = await transaction.get(loginRef);
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) return false;
      final data = login.data() ?? {};
      final userData = userSnapshot.data() ?? {};
      if (data['lastLoginDate'] == today && data['claimedToday'] == true) {
        return false;
      }
      final streak = (data['currentStreak'] as num?)?.toInt() ?? 0;
      final nextStreak = streak + 1;
      final rewardId = 'day_${((nextStreak - 1) % 7) + 1}';
      final reward = await transaction.get(
        _firestore.doc('${FirestorePaths.dailyLoginRewards}/$rewardId'),
      );
      final rewardData = reward.data() ?? {};

      // Fallback: jika dokumen reward belum ada di Firestore, pakai nilai default
      final rewardCoin = (rewardData['rewardCoin'] as num?)?.toInt() ?? 100;
      final rewardXp = (rewardData['rewardXp'] as num?)?.toInt() ?? 50;
      final instrumentId = rewardData['rewardInstrumentId']?.toString() ?? '';
      DocumentSnapshot<Map<String, dynamic>>? ownershipSnapshot;
      if (instrumentId.isNotEmpty) {
        ownershipSnapshot = await transaction.get(
          _firestore.doc(FirestorePaths.userInstrument(user.uid, instrumentId)),
        );
      }
      final nextXp = _numberValue(userData['xp']) + rewardXp;
      final nextCoin = _numberValue(userData['coin']) + rewardCoin;
      final nextLevel = max(1, (nextXp / 500).floor() + 1);
      final quizCompleted = _numberValue(userData['quizCompleted']);
      final isNewInstrument =
          instrumentId.isNotEmpty &&
          (ownershipSnapshot == null ||
              ownershipSnapshot.data()?['isUnlocked'] != true);
      final nextOwnedInstrumentCount =
          _numberValue(userData['ownedInstrumentCount']) +
          (isNewInstrument ? 1 : 0);

      transaction.set(loginRef, {
        'currentStreak': nextStreak,
        'lastLoginDate': today,
        'claimedToday': true,
        'totalLoginDays': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(userRef, {
        'xp': nextXp,
        'coin': nextCoin,
        'level': nextLevel,
        'ownedInstrumentCount': nextOwnedInstrumentCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(
        leaderboardRef,
        _leaderboardData(
          userData,
          xp: nextXp,
          level: nextLevel,
          quizCompleted: quizCompleted,
        ),
        SetOptions(merge: true),
      );
      if (instrumentId.isNotEmpty) {
        transaction.set(
          _firestore.doc(FirestorePaths.userInstrument(user.uid, instrumentId)),
          {
            'isUnlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
            'source': 'daily_login',
          },
          SetOptions(merge: true),
        );
      }
      return isNewInstrument;
    });
    if (unlockedNewInstrument) {
      await MissionService.instance.incrementProgress(
        'unlock_instrument',
        by: 1,
      );
    }
    await BadgeService.instance.checkAndAwardBadges();
  }
}

class InstrumentMasteryService {
  InstrumentMasteryService({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  static final InstrumentMasteryService instance = InstrumentMasteryService();

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  Future<void> markMastered(String instrumentId) async {
    final user = _auth.currentUser;
    if (user == null || instrumentId.isEmpty) return;

    final masteryRef = _firestore.doc(
      '${FirestorePaths.user(user.uid)}/instrument_mastery/$instrumentId',
    );
    final userRef = _firestore.doc(FirestorePaths.user(user.uid));

    await _firestore.runTransaction((transaction) async {
      final masterySnapshot = await transaction.get(masteryRef);
      if (masterySnapshot.exists) return;

      transaction.set(masteryRef, {
        'instrumentId': instrumentId,
        'masteredAt': FieldValue.serverTimestamp(),
      });
      transaction.set(userRef, {
        'instrumentMasteryCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    await BadgeService.instance.checkAndAwardBadges();
  }
}

class BadgeService {
  BadgeService({FirebaseFirestore? firestore, auth.FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  static final BadgeService instance = BadgeService();

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  Future<void> checkAndAwardBadges() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final badges = await _firestore
        .collection(FirestorePaths.achievements)
        .where('isActive', isEqualTo: true)
        .get();
    final userRef = _firestore.doc(FirestorePaths.user(user.uid));
    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) return;
      final userData = userSnapshot.data()!;
      final badgeRefs = [
        for (final badge in badges.docs)
          _firestore.doc(FirestorePaths.userBadge(user.uid, badge.id)),
      ];
      final badgeSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final badgeRef in badgeRefs) {
        badgeSnapshots.add(await transaction.get(badgeRef));
      }

      var awarded = 0;
      for (var i = 0; i < badges.docs.length; i++) {
        final badge = badges.docs[i];
        final data = badge.data();
        final badgeRef = badgeRefs[i];
        final badgeSnapshot = badgeSnapshots[i];
        if (badgeSnapshot.exists) continue;
        if (_badgeConditionMet(data, userData)) {
          transaction.set(badgeRef, {'earnedAt': FieldValue.serverTimestamp()});
          awarded += 1;
        }
      }
      if (awarded > 0) {
        transaction.set(userRef, {
          'badgesEarned': FieldValue.increment(awarded),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  bool _badgeConditionMet(
    Map<String, dynamic> badge,
    Map<String, dynamic> user,
  ) {
    final type = badge['conditionType']?.toString() ?? '';
    final value = (badge['conditionValue'] as num?)?.toInt() ?? 0;
    switch (type) {
      case 'account_created':
        return true;
      case 'quiz_completed':
        return ((user['quizCompleted'] as num?)?.toInt() ?? 0) >= value;
      case 'perfect_score':
        return ((user['perfectScoreCount'] as num?)?.toInt() ?? 0) >= value;
      case 'xp_reached':
        return ((user['xp'] as num?)?.toInt() ?? 0) >= value;
      case 'instrument_collected':
        return ((user['ownedInstrumentCount'] as num?)?.toInt() ?? 0) >= value;
      case 'instrument_mastery':
        return ((user['instrumentMasteryCount'] as num?)?.toInt() ?? 0) >=
            value;
      default:
        return false;
    }
  }
}
