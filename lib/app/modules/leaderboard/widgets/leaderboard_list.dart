import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/utils/number_formatter.dart';
import 'package:swaranusaquiz/app/data/models/leaderboard_user.dart';

class LeaderboardList extends StatelessWidget {
  final List<LeaderboardUser> users;
  final String? currentUserId;

  const LeaderboardList({
    super.key,
    required this.users,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan padding dinamis agar tidak terpotong navbar/gesture bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return ListView.builder(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: bottomPadding),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LeaderboardListItem(
            rank: user.rank,
            user: user,
            isCurrentUser: user.id == currentUserId,
          ),
        );
      },
    );
  }
}

class LeaderboardListItem extends StatelessWidget {
  final int rank;
  final LeaderboardUser user;
  final bool isCurrentUser;

  const LeaderboardListItem({
    super.key,
    required this.rank,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedScore = NumberFormatter.compactThousands(user.score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.secondary : AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : AppColors.divider,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 2),
              image: DecorationImage(
                image: _avatarImage(user.avatarPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Skor: $formattedScore',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Anda',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            formattedScore,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _avatarImage(String? path) {
    if (path != null && path.startsWith('http')) {
      return NetworkImage(path);
    }
    return AssetImage(path ?? 'assets/image/profil1.png');
  }
}
