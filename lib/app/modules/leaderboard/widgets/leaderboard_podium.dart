import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/utils/number_formatter.dart';
import 'package:swaranusaquiz/app/data/models/leaderboard_user.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardUser> users;

  const LeaderboardPodium({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        height: 160,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (users.length >= 2)
              Expanded(child: _PodiumItem(user: users[1], avatarSize: 76)),
            const SizedBox(width: 20),
            if (users.isNotEmpty)
              Expanded(child: _PodiumItem(user: users[0], avatarSize: 96)),
            const SizedBox(width: 20),
            if (users.length >= 3)
              Expanded(child: _PodiumItem(user: users[2], avatarSize: 76)),
          ],
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardUser user;
  final double avatarSize;

  const _PodiumItem({required this.user, required this.avatarSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(
                  user.avatarPath ?? 'assets/image/profil1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          user.name,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormatter.compactThousands(user.score),
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
