class LeaderboardUser {
  final int id;
  final String name;
  final int score;
  final String? avatarPath;

  const LeaderboardUser({
    required this.id,
    required this.name,
    required this.score,
    this.avatarPath,
  });
}

class LeaderboardData {
  const LeaderboardData._();

  static List<LeaderboardUser> getSampleData() {
    return const [
      LeaderboardUser(
        id: 1,
        name: 'Ahmad',
        score: 12500,
        avatarPath: 'assets/image/juara1.png',
      ),
      LeaderboardUser(
        id: 2,
        name: 'Maya',
        score: 11800,
        avatarPath: 'assets/image/silver.png',
      ),
      LeaderboardUser(
        id: 3,
        name: 'Joko',
        score: 11200,
        avatarPath: 'assets/image/bronze.png',
      ),
      LeaderboardUser(id: 4, name: 'Citra', score: 10500),
      LeaderboardUser(id: 5, name: 'Joko', score: 9800),
      LeaderboardUser(id: 6, name: 'Rani', score: 9200),
      LeaderboardUser(id: 7, name: 'Anda', score: 8500),
      LeaderboardUser(id: 8, name: 'Rani', score: 9200),
      LeaderboardUser(id: 9, name: 'Rani', score: 9200),
      LeaderboardUser(id: 10, name: 'Rani', score: 7800),
      LeaderboardUser(id: 11, name: 'Rani', score: 5200),
      LeaderboardUser(id: 12, name: 'Rani', score: 5000),
    ];
  }
}
