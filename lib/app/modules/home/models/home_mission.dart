class HomeMission {
  final String iconPath;
  final String title;
  final int progress;
  final int total;
  final int reward;
  final bool isCompleted;

  const HomeMission({
    required this.iconPath,
    required this.title,
    required this.progress,
    required this.total,
    required this.reward,
    this.isCompleted = false,
  });
}
