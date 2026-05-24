import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:swaranusaquiz/app/data/providers/backend_bootstrap.dart';
import 'package:swaranusaquiz/app/data/providers/firestore_paths.dart';

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

  const QuizSessionSummary({
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    required this.score,
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
  bool _isFinished = false;
  QuizSessionSummary? _lastSummary;

  QuizSessionSummary? get lastSummary => _lastSummary;
  List<QuizAnswerRecord> get answers => List.unmodifiable(_answers);

  void start({
    String modeId = 'tebak_gambar',
    String levelId = 'tebak_gambar_1',
    int totalQuestions = 10,
  }) {
    _answers.clear();
    _startedAt = DateTime.now();
    _modeId = modeId;
    _levelId = levelId;
    _totalQuestions = totalQuestions;
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
      );
    }
    final question = BackendBootstrap.instance.questionsById[questionId];
    final authoritativeCorrectAnswer = question?.correctAnswer ?? correctAnswer;
    final authoritativePoints = question?.points ?? points;
    final isCorrect = selectedAnswer == authoritativeCorrectAnswer;
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
    );
  }

  Future<QuizSessionSummary> finish() async {
    if (_isFinished) return _lastSummary ?? currentSummary();
    _isFinished = true;
    final summary = currentSummary();
    _lastSummary = summary;

    final user = _auth.currentUser;
    if (user == null) return summary;

    final attemptId = _firestore.collection('_ids').doc().id;
    final startedAt = _startedAt ?? DateTime.now();
    final durationSeconds = DateTime.now().difference(startedAt).inSeconds;
    final earnedXp = summary.correctAnswers * 15;
    final earnedCoin = summary.correctAnswers * 5;

    final userRef = _firestore.doc(FirestorePaths.user(user.uid));
    final attemptRef = _firestore.doc(
      FirestorePaths.userQuizAttempt(user.uid, attemptId),
    );
    final levelProgressRef = _firestore.doc(
      FirestorePaths.userLevelProgress(user.uid, _levelId),
    );
    final nextLevel = _nextLevelId(_levelId);
    final nextLevelRef = nextLevel == null
        ? null
        : _firestore.doc(FirestorePaths.userLevelProgress(user.uid, nextLevel));
    final leaderboardRef = _firestore.doc(
      FirestorePaths.leaderboardEntry('global', user.uid),
    );

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final userData = userSnapshot.data() ?? {};
      final currentXp = (userData['xp'] as num?)?.toInt() ?? 0;
      final currentCoin = (userData['coin'] as num?)?.toInt() ?? 0;
      final quizCompleted = (userData['quizCompleted'] as num?)?.toInt() ?? 0;
      final correctCount =
          (userData['correctAnswerCount'] as num?)?.toInt() ?? 0;
      final wrongCount = (userData['wrongAnswerCount'] as num?)?.toInt() ?? 0;
      final newXp = currentXp + earnedXp;
      final newCoin = currentCoin + earnedCoin;
      final newLevel = max(1, (newXp / 500).floor() + 1);

      transaction.set(attemptRef, {
        'modeId': _modeId,
        'levelId': _levelId,
        'totalQuestions': summary.totalQuestions,
        'correctAnswers': summary.correctAnswers,
        'wrongAnswers': summary.wrongAnswers,
        'score': summary.score,
        'earnedXp': earnedXp,
        'earnedCoin': earnedCoin,
        'durationSeconds': durationSeconds,
        'startedAt': Timestamp.fromDate(startedAt),
        'finishedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (final answer in _answers) {
        transaction.set(
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

      transaction.set(userRef, {
        'xp': newXp,
        'coin': newCoin,
        'level': newLevel,
        'quizCompleted': quizCompleted + 1,
        'correctAnswerCount': correctCount + summary.correctAnswers,
        'wrongAnswerCount': wrongCount + summary.wrongAnswers,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(levelProgressRef, {
        'modeId': _modeId,
        'status': 'completed',
        'isUnlocked': true,
        'stars': _starsForScore(summary.score),
        'bestScore': summary.score,
        'bestCorrectAnswers': summary.correctAnswers,
        'attemptCount': FieldValue.increment(1),
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (nextLevelRef != null) {
        transaction.set(nextLevelRef, {
          'modeId': _modeId,
          'status': 'unlocked',
          'isUnlocked': true,
          'stars': 0,
          'bestScore': 0,
          'bestCorrectAnswers': 0,
          'attemptCount': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      transaction.set(leaderboardRef, {
        'periodType': 'global',
        'periodKey': 'global',
        'name': userData['name'] ?? user.displayName ?? user.email ?? 'User',
        'username': userData['username'] ?? '',
        'avatarUrl': userData['avatarUrl'] ?? '',
        'level': newLevel,
        'xp': newXp,
        'score': newXp,
        'quizCompleted': quizCompleted + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    await MissionService.instance.incrementProgress('play_game', by: 1);
    await MissionService.instance.incrementProgress('complete_quiz', by: 1);
    await BadgeService.instance.checkAndAwardBadges();
    return summary;
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
    final missions = await _firestore
        .collection(FirestorePaths.missions)
        .where('targetType', isEqualTo: targetType)
        .where('isActive', isEqualTo: true)
        .get();
    if (missions.docs.isEmpty) return;

    await _firestore.runTransaction((transaction) async {
      for (final mission in missions.docs) {
        final data = mission.data();
        final target = (data['targetValue'] as num?)?.toInt() ?? 0;
        final progressRef = _firestore.doc(
          FirestorePaths.userMissionProgress(user.uid, mission.id),
        );
        final progressSnapshot = await transaction.get(progressRef);
        final progressData = progressSnapshot.data() ?? {};
        final current = (progressData['progress'] as num?)?.toInt() ?? 0;
        final next = min(target, current + by);
        transaction.set(progressRef, {
          'progress': next,
          'target': target,
          'isCompleted': target > 0 && next >= target,
          'isClaimed': progressData['isClaimed'] == true,
          'dateKey': DateTime.now().toIso8601String().substring(0, 10),
          'completedAt': target > 0 && next >= target
              ? FieldValue.serverTimestamp()
              : progressData['completedAt'],
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
    await _firestore.runTransaction((transaction) async {
      final mission = await transaction.get(missionRef);
      final progress = await transaction.get(progressRef);
      if (!mission.exists || !progress.exists) return;
      final missionData = mission.data() as Map<String, dynamic>;
      final progressData = progress.data() as Map<String, dynamic>;
      if (progressData['isCompleted'] != true ||
          progressData['isClaimed'] == true) {
        return;
      }
      transaction.set(progressRef, {
        'isClaimed': true,
        'claimedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(userRef, {
        'xp': FieldValue.increment(
          (missionData['rewardXp'] as num?)?.toInt() ?? 0,
        ),
        'coin': FieldValue.increment(
          (missionData['rewardCoin'] as num?)?.toInt() ?? 0,
        ),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      final rewardInstrumentId =
          missionData['rewardInstrumentId']?.toString() ?? '';
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
    });
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

    await _firestore.runTransaction((transaction) async {
      final instrument = await transaction.get(instrumentRef);
      final ownership = await transaction.get(ownershipRef);
      final userSnapshot = await transaction.get(userRef);
      if (!instrument.exists || !userSnapshot.exists) return;
      final owned =
          ownership.exists && (ownership.data()?['isUnlocked'] == true);
      if (owned) return;
      final instrumentData = instrument.data()!;
      final userData = userSnapshot.data()!;
      final price = (instrumentData['price'] as num?)?.toInt() ?? 0;
      final coin = (userData['coin'] as num?)?.toInt() ?? 0;
      if (coin < price) {
        throw StateError('Coin tidak cukup');
      }
      transaction.set(userRef, {
        'coin': coin - price,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(ownershipRef, {
        'isUnlocked': true,
        'unlockedAt': FieldValue.serverTimestamp(),
        'source': 'coin_purchase',
      }, SetOptions(merge: true));
    });

    await MissionService.instance.incrementProgress('unlock_instrument', by: 1);
    await BadgeService.instance.checkAndAwardBadges();
  }

  Future<void> claimDailyLogin() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final loginRef = _firestore.doc(FirestorePaths.userDailyLogin(user.uid));
    final userRef = _firestore.doc(FirestorePaths.user(user.uid));

    await _firestore.runTransaction((transaction) async {
      final login = await transaction.get(loginRef);
      final data = login.data() ?? {};
      if (data['lastLoginDate'] == today && data['claimedToday'] == true)
        return;
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

      transaction.set(loginRef, {
        'currentStreak': nextStreak,
        'lastLoginDate': today,
        'claimedToday': true,
        'totalLoginDays': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(userRef, {
        'xp': FieldValue.increment(rewardXp),
        'coin': FieldValue.increment(rewardCoin),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      final instrumentId = rewardData['rewardInstrumentId']?.toString() ?? '';
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
    });
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
      var awarded = 0;
      for (final badge in badges.docs) {
        final data = badge.data();
        final badgeRef = _firestore.doc(
          FirestorePaths.userBadge(user.uid, badge.id),
        );
        final badgeSnapshot = await transaction.get(badgeRef);
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
        return false;
      case 'xp_reached':
        return ((user['xp'] as num?)?.toInt() ?? 0) >= value;
      case 'instrument_collected':
      case 'instrument_mastery':
        return false;
      default:
        return false;
    }
  }
}
