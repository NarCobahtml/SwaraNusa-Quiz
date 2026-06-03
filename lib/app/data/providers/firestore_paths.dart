class FirestorePaths {
  const FirestorePaths._();

  static const users = 'users';
  static const quizModes = 'quiz_modes';
  static const levels = 'levels';
  static const questions = 'questions';
  static const instruments = 'instruments';
  static const missions = 'missions';
  static const achievements = 'achievements';
  static const badges = achievements;
  static const dailyLoginRewards = 'daily_login_rewards';
  static const leaderboards = 'leaderboards';
  static const appConfig = 'app_config';
  static const seasonConfig = '$appConfig/season';

  static String user(String uid) => '$users/$uid';
  static String userLevelProgress(String uid, String levelId) =>
      '$users/$uid/level_progress/$levelId';
  static String userSeasonLevels(String uid, String seasonId) =>
      '$users/$uid/season_progress/$seasonId/levels';
  static String userSeasonLevelProgress(
    String uid,
    String seasonId,
    String levelId,
  ) =>
      '${userSeasonLevels(uid, seasonId)}/$levelId';
  static String userQuizAttempt(String uid, String attemptId) =>
      '$users/$uid/quiz_attempts/$attemptId';
  static String userQuizAttemptAnswer(
    String uid,
    String attemptId,
    String answerId,
  ) =>
      '$users/$uid/quiz_attempts/$attemptId/answers/$answerId';
  static String userMissionProgress(String uid, String missionId) =>
      '$users/$uid/mission_progress/$missionId';
  static String userInstrument(String uid, String instrumentId) =>
      '$users/$uid/owned_instruments/$instrumentId';
  static String userAchievements(String uid) => '$users/$uid/achievements';
  static String userBadge(String uid, String badgeId) =>
      '$users/$uid/achievements/$badgeId';
  static String userDailyLogin(String uid) => '$users/$uid/daily_login/current';
  static String userDailyQuiz(String uid, String dateKey) =>
      '$users/$uid/daily_quiz/$dateKey';
  static String leaderboardEntry(String periodKey, String uid) =>
      '$leaderboards/$periodKey/entries/$uid';
}
