import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/utils/number_formatter.dart';
import 'package:swaranusaquiz/app/data/models/leaderboard_user.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardUser> users;
  final String? currentUserId;

  const LeaderboardPodium({
    super.key,
    required this.users,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        height: 190,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (users.length >= 2)
              Expanded(
                child: _PodiumItem(
                  user: users[1],
                  avatarSize: 76,
                  isCurrentUser: users[1].id == currentUserId,
                ),
              ),
            const SizedBox(width: 20),
            if (users.isNotEmpty)
              Expanded(
                child: _PodiumItem(
                  user: users[0],
                  avatarSize: 96,
                  isCurrentUser: users[0].id == currentUserId,
                ),
              ),
            const SizedBox(width: 20),
            if (users.length >= 3)
              Expanded(
                child: _PodiumItem(
                  user: users[2],
                  avatarSize: 76,
                  isCurrentUser: users[2].id == currentUserId,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardUser user;
  final double avatarSize;
  final bool isCurrentUser;

  const _PodiumItem({
    required this.user,
    required this.avatarSize,
    required this.isCurrentUser,
  });

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
            border: Border.all(
              color: isCurrentUser ? AppColors.gold : Colors.transparent,
              width: isCurrentUser ? 3 : 0,
            ),
            image: DecorationImage(
              image: _avatarImage(user.avatarPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            Text(
              user.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isCurrentUser) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        SizedBox(height: isCurrentUser ? 3 : 4),
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

  ImageProvider _avatarImage(String? path) {
    if (path != null && path.startsWith('http')) {
      return NetworkImage(path);
    }
    return AssetImage(path ?? 'assets/image/profil1.png');
  }
}
