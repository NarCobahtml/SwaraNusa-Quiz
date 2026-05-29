import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/profile/models/profile_badge.dart';

class ProfileBadgesSection extends StatelessWidget {
  final List<ProfileBadge> badges;

  const ProfileBadgesSection({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lencana',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 0),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
            children: [
              for (final badge in badges) ProfileBadgeItem(badge: badge),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileBadgeItem extends StatelessWidget {
  final ProfileBadge badge;

  const ProfileBadgeItem({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: Center(
            child: badge.iconUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      badge.iconUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _BadgeStars(stars: badge.stars),
                    ),
                  )
                : _BadgeStars(stars: badge.stars),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _BadgeStars extends StatelessWidget {
  final int stars;

  const _BadgeStars({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        stars > 3 ? 3 : stars,
        (index) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: stars == 1 ? 0 : (stars == 2 ? 2 : 1),
          ),
          child: Icon(
            Icons.star,
            color: AppColors.gold,
            size: stars == 1
                ? 32
                : stars == 2
                ? 24
                : stars == 3
                ? 20
                : stars == 4
                ? 18
                : 16,
          ),
        ),
      ),
    );
  }
}
