import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/home/models/home_profile.dart';

class HomeProfileCard extends StatelessWidget {
  final HomeProfile profile;

  const HomeProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 3),
                ),
                child: ClipOval(
                  child: _HomeAvatar(imagePath: profile.avatarPath),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textLight, width: 2),
                  ),
                  child: Text(
                    '${profile.level}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const ImageIcon(
                      AssetImage('assets/image/icon_xp.png'),
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.xp} XP',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAvatar extends StatelessWidget {
  final String imagePath;

  const _HomeAvatar({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath.isNotEmpty && !imagePath.startsWith('assets')) {
      return Image.network(
        imagePath,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const _AvatarPlaceholder(),
      );
    }

    return Image.asset(
      imagePath,
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textLight,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 36,
      ),
    );
  }
}
