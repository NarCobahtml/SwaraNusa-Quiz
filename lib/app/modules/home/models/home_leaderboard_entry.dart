class HomeLeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final String? avatarPath;
  final bool isCurrentUser;

  const HomeLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    this.avatarPath,
    this.isCurrentUser = false,
  });
}
