import 'package:swaranusaquiz/app/data/models/backend_models.dart';

class LeaderboardUser {
  final String id;
  final int rank;
  final String name;
  final String username;
  final int score;
  final String? avatarPath;

  const LeaderboardUser({
    required this.id,
    required this.rank,
    required this.name,
    this.username = '',
    required this.score,
    this.avatarPath,
  });

  factory LeaderboardUser.fromDoc(LeaderboardEntryDoc doc) {
    return LeaderboardUser(
      id: doc.uid,
      rank: doc.rank,
      name: doc.name.isEmpty ? 'User' : doc.name,
      username: doc.username,
      score: doc.score,
      avatarPath: doc.avatarUrl.isEmpty ? null : doc.avatarUrl,
    );
  }
}
