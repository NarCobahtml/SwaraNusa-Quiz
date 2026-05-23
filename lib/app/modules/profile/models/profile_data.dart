class ProfileData {
  final String name;
  final String handle;
  final String avatarPath;
  final int quizCompleted;
  final int correctAnswerPercentage;
  final int badgesEarned;

  const ProfileData({
    required this.name,
    required this.handle,
    required this.avatarPath,
    required this.quizCompleted,
    required this.correctAnswerPercentage,
    required this.badgesEarned,
  });
}
