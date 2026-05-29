class RewardMission {
  final String id;
  final String title;
  final double progress;
  final int progressValue;
  final int targetValue;
  final int rewardCoin;
  final int rewardXp;
  final bool isCompleted;
  final bool isClaimed;

  const RewardMission({
    required this.id,
    required this.title,
    required this.progress,
    required this.progressValue,
    required this.targetValue,
    required this.rewardCoin,
    this.rewardXp = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });
}
