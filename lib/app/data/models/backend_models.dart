import 'package:cloud_firestore/cloud_firestore.dart';

int _intValue(Object? value) => value is num ? value.toInt() : 0;
bool _boolValue(Object? value) => value == true;
String _stringValue(Object? value) => value?.toString() ?? '';
String _firstStringValue(
  Map<String, dynamic> data,
  List<String> fieldNames,
) {
  for (final fieldName in fieldNames) {
    final value = _stringValue(data[fieldName]).trim();
    if (value.isNotEmpty) return value;
  }
  return '';
}
List<String> _stringList(Object? value) {
  if (value is Iterable) return value.map((item) => item.toString()).toList();
  return const [];
}

class AppUser {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String avatarUrl;
  final int level;
  final int xp;
  final int coin;
  final int quizCompleted;
  final int correctAnswerCount;
  final int wrongAnswerCount;
  final int perfectScoreCount;
  final int ownedInstrumentCount;
  final int instrumentMasteryCount;
  final int badgesEarned;

  const AppUser({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.level,
    required this.xp,
    required this.coin,
    required this.quizCompleted,
    required this.correctAnswerCount,
    required this.wrongAnswerCount,
    this.perfectScoreCount = 0,
    this.ownedInstrumentCount = 0,
    this.instrumentMasteryCount = 0,
    required this.badgesEarned,
  });

  factory AppUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return AppUser(
      uid: snapshot.id,
      name: _stringValue(data['name']),
      username: _stringValue(data['username']),
      email: _stringValue(data['email']),
      avatarUrl: _stringValue(data['avatarUrl']),
      level: _intValue(data['level']),
      xp: _intValue(data['xp']),
      coin: _intValue(data['coin']),
      quizCompleted: _intValue(data['quizCompleted']),
      correctAnswerCount: _intValue(data['correctAnswerCount']),
      wrongAnswerCount: _intValue(data['wrongAnswerCount']),
      perfectScoreCount: _intValue(data['perfectScoreCount']),
      ownedInstrumentCount: _intValue(data['ownedInstrumentCount']),
      instrumentMasteryCount: _intValue(data['instrumentMasteryCount']),
      badgesEarned: _intValue(data['badgesEarned']),
    );
  }

  Map<String, Object?> toCreateMap() => {
        'name': name,
        'username': username,
        'email': email,
        'avatarUrl': avatarUrl,
        'level': level,
        'xp': xp,
        'coin': coin,
        'quizCompleted': quizCompleted,
        'correctAnswerCount': correctAnswerCount,
        'wrongAnswerCount': wrongAnswerCount,
        'perfectScoreCount': perfectScoreCount,
        'ownedInstrumentCount': ownedInstrumentCount,
        'instrumentMasteryCount': instrumentMasteryCount,
        'badgesEarned': badgesEarned,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class QuizModeDoc {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final int order;
  final bool isActive;

  const QuizModeDoc({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.order,
    required this.isActive,
  });

  factory QuizModeDoc.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return QuizModeDoc(
      id: snapshot.id,
      title: _stringValue(data['title']),
      description: _stringValue(data['description']),
      iconUrl: _stringValue(data['iconUrl']),
      order: _intValue(data['order']),
      isActive: _boolValue(data['isActive']),
    );
  }
}

class LevelDoc {
  final String id;
  final String modeId;
  final int levelNumber;
  final String title;
  final int totalQuestions;
  final int requiredXp;
  final String unlockAfterLevelId;
  final int rewardXp;
  final int rewardCoin;
  final bool isActive;

  const LevelDoc({
    required this.id,
    required this.modeId,
    required this.levelNumber,
    required this.title,
    required this.totalQuestions,
    required this.requiredXp,
    required this.unlockAfterLevelId,
    required this.rewardXp,
    required this.rewardCoin,
    required this.isActive,
  });

  factory LevelDoc.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return LevelDoc(
      id: snapshot.id,
      modeId: _stringValue(data['modeId']),
      levelNumber: _intValue(data['levelNumber']),
      title: _stringValue(data['title']),
      totalQuestions: _intValue(data['totalQuestions']),
      requiredXp: _intValue(data['requiredXp']),
      unlockAfterLevelId: _stringValue(data['unlockAfterLevelId']),
      rewardXp: _intValue(data['rewardXp']),
      rewardCoin: _intValue(data['rewardCoin']),
      isActive: _boolValue(data['isActive']),
    );
  }
}

class QuestionDoc {
  final String id;
  final String modeId;
  final String levelId;
  final int questionNumber;
  final String title;
  final String questionText;
  final String mediaType;
  final String mediaUrl;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final int timeLimitSeconds;
  final int points;
  final bool isActive;

  const QuestionDoc({
    required this.id,
    required this.modeId,
    required this.levelId,
    required this.questionNumber,
    required this.title,
    required this.questionText,
    required this.mediaType,
    required this.mediaUrl,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.timeLimitSeconds,
    required this.points,
    required this.isActive,
  });

  factory QuestionDoc.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return QuestionDoc(
      id: snapshot.id,
      modeId: _stringValue(data['modeId']),
      levelId: _stringValue(data['levelId']),
      questionNumber: _intValue(data['questionNumber']),
      title: _stringValue(data['title']),
      questionText: _stringValue(data['questionText']),
      mediaType: _stringValue(data['mediaType']),
      mediaUrl: _stringValue(data['mediaUrl']),
      options: _stringList(data['options']),
      correctAnswer: _stringValue(data['correctAnswer']),
      explanation: _stringValue(data['explanation']),
      timeLimitSeconds: _intValue(data['timeLimitSeconds']),
      points: _intValue(data['points']),
      isActive: _boolValue(data['isActive']),
    );
  }
}

class UserLevelProgressDoc {
  final String levelId;
  final String modeId;
  final String status;
  final bool isUnlocked;
  final int stars;
  final int bestScore;
  final int bestCorrectAnswers;
  final int attemptCount;

  const UserLevelProgressDoc({
    required this.levelId,
    required this.modeId,
    required this.status,
    required this.isUnlocked,
    required this.stars,
    required this.bestScore,
    required this.bestCorrectAnswers,
    required this.attemptCount,
  });

  factory UserLevelProgressDoc.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return UserLevelProgressDoc(
      levelId: snapshot.id,
      modeId: _stringValue(data['modeId']),
      status: _stringValue(data['status']),
      isUnlocked: _boolValue(data['isUnlocked']),
      stars: _intValue(data['stars']),
      bestScore: _intValue(data['bestScore']),
      bestCorrectAnswers: _intValue(data['bestCorrectAnswers']),
      attemptCount: _intValue(data['attemptCount']),
    );
  }
}

class InstrumentDoc {
  final String id;
  final String name;
  final String region;
  final String imageUrl;
  final List<String> noteUrls;
  final int sortOrder;
  final int price;
  final bool opensMinigame;
  final bool isActive;
  final bool owned;

  const InstrumentDoc({
    required this.id,
    required this.name,
    required this.region,
    required this.imageUrl,
    required this.noteUrls,
    required this.sortOrder,
    required this.price,
    required this.opensMinigame,
    required this.isActive,
    this.owned = false,
  });

  InstrumentDoc copyWith({bool? owned}) => InstrumentDoc(
        id: id,
        name: name,
        region: region,
        imageUrl: imageUrl,
        noteUrls: noteUrls,
        sortOrder: sortOrder,
        price: price,
        opensMinigame: opensMinigame,
        isActive: isActive,
        owned: owned ?? this.owned,
      );

  factory InstrumentDoc.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return InstrumentDoc(
      id: snapshot.id,
      name: _stringValue(data['name']),
      region: _stringValue(data['region']),
      imageUrl: _firstStringValue(data, const [
        'imageUrl',
        'imageURL',
        'image',
        'imagePath',
        'coverUrl',
        'coverImageUrl',
        'iconUrl',
        'photoUrl',
        'thumbnailUrl',
      ]),
      noteUrls: _stringList(data['noteUrls']),
      sortOrder: _intValue(data['sortOrder']),
      price: _intValue(data['price']),
      opensMinigame: _boolValue(data['opensMinigame']),
      isActive: _boolValue(data['isActive']),
    );
  }
}

class MissionDoc {
  final String id;
  final String title;
  final String description;
  final String type;
  final String targetType;
  final int targetValue;
  final int rewardXp;
  final int rewardCoin;
  final String rewardInstrumentId;
  final String iconUrl;
  final bool isActive;

  const MissionDoc({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetType,
    required this.targetValue,
    required this.rewardXp,
    required this.rewardCoin,
    required this.rewardInstrumentId,
    required this.iconUrl,
    required this.isActive,
  });

  factory MissionDoc.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return MissionDoc(
      id: snapshot.id,
      title: _stringValue(data['title']),
      description: _stringValue(data['description']),
      type: _stringValue(data['type']),
      targetType: _stringValue(data['targetType']),
      targetValue: _intValue(data['targetValue']),
      rewardXp: _intValue(data['rewardXp']),
      rewardCoin: _intValue(data['rewardCoin']),
      rewardInstrumentId: _stringValue(data['rewardInstrumentId']),
      iconUrl: _stringValue(data['iconUrl']),
      isActive: _boolValue(data['isActive']),
    );
  }
}

class MissionProgressDoc {
  final String missionId;
  final int progress;
  final int target;
  final String dateKey;
  final bool isCompleted;
  final bool isClaimed;

  const MissionProgressDoc({
    required this.missionId,
    required this.progress,
    required this.target,
    required this.dateKey,
    required this.isCompleted,
    required this.isClaimed,
  });

  factory MissionProgressDoc.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return MissionProgressDoc(
      missionId: snapshot.id,
      progress: _intValue(data['progress']),
      target: _intValue(data['target']),
      dateKey: _stringValue(data['dateKey']),
      isCompleted: _boolValue(data['isCompleted']),
      isClaimed: _boolValue(data['isClaimed']),
    );
  }
}

class BadgeDoc {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int stars;
  final String conditionType;
  final int conditionValue;
  final bool isActive;

  const BadgeDoc({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.stars,
    required this.conditionType,
    required this.conditionValue,
    required this.isActive,
  });

  factory BadgeDoc.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return BadgeDoc(
      id: snapshot.id,
      name: _stringValue(data['name']),
      description: _stringValue(data['description']),
      iconUrl: _stringValue(data['iconUrl']),
      stars: _intValue(data['stars']),
      conditionType: _stringValue(data['conditionType']),
      conditionValue: _intValue(data['conditionValue']),
      isActive: _boolValue(data['isActive']),
    );
  }
}

class LeaderboardEntryDoc {
  final String uid;
  final int rank;
  final String name;
  final String username;
  final String avatarUrl;
  final int level;
  final int xp;
  final int score;
  final int quizCompleted;

  const LeaderboardEntryDoc({
    required this.uid,
    required this.rank,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.level,
    required this.xp,
    required this.score,
    required this.quizCompleted,
  });

  factory LeaderboardEntryDoc.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return LeaderboardEntryDoc(
      uid: snapshot.id,
      rank: _intValue(data['rank']),
      name: _stringValue(data['name']),
      username: _stringValue(data['username']),
      avatarUrl: _stringValue(data['avatarUrl']),
      level: _intValue(data['level']),
      xp: _intValue(data['xp']),
      score: _intValue(data['score']),
      quizCompleted: _intValue(data['quizCompleted']),
    );
  }
}
