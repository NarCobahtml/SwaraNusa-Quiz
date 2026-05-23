class HomeLeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final bool isCurrentUser;

  const HomeLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    this.isCurrentUser = false,
  });
}
