class LevelData {
  final int number;
  final String status;
  final int stars;

  const LevelData({
    required this.number,
    this.status = 'locked',
    this.stars = 0,
  });

  bool get isLocked => status == 'locked';
  bool get isCompleted => status == 'completed';
}
