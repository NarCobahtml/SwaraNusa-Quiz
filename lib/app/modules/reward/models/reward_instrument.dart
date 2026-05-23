class RewardInstrument {
  final String imagePath;
  final String name;
  final String region;
  final bool opensMinigame;

  const RewardInstrument({
    required this.imagePath,
    required this.name,
    required this.region,
    this.opensMinigame = false,
  });
}
