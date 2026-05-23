import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/utils/number_formatter.dart';
import 'package:swaranusaquiz/app/data/models/leaderboard_user.dart';

class LeaderboardList extends StatelessWidget {
  final List<LeaderboardUser> users;
  final int? currentUserId;

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
        final rank = index + 4;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LeaderboardListItem(
            rank: rank,
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
              image: const DecorationImage(
                image: AssetImage('assets/image/profil1.png'),
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
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Skor: $formattedScore',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
}
