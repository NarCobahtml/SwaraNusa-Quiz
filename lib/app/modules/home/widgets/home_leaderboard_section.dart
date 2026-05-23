import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/home/models/home_leaderboard_entry.dart';

class HomeLeaderboardSection extends StatelessWidget {
  final List<HomeLeaderboardEntry> entries;

  const HomeLeaderboardSection({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          HomeLeaderboardItem(entry: entries[index]),
        ],
      ],
    );
  }
}

class HomeLeaderboardItem extends StatelessWidget {
  final HomeLeaderboardEntry entry;

  const HomeLeaderboardItem({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppColors.secondary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: entry.isCurrentUser
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            entry.rank == 1
                ? Icons.emoji_events
                : Icons.emoji_events_outlined,
            color: entry.rank == 1 ? AppColors.gold : AppColors.textMuted,
            size: 28,
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            child: Image.asset('assets/image/user_papan.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${entry.xp} XP',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${entry.rank}',
            style: TextStyle(
              color: entry.rank == 1
                  ? AppColors.gold
                  : entry.rank == 2
                      ? AppColors.textMuted
                      : AppColors.textMuted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
