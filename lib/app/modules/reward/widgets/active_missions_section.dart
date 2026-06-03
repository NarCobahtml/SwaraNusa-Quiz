import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/reward/models/reward_mission.dart';

class ActiveMissionsSection extends StatelessWidget {
  final List<RewardMission> missions;
  final ValueChanged<RewardMission> onClaimMission;
  final String? claimingMissionId;

  const ActiveMissionsSection({
    super.key,
    required this.missions,
    required this.onClaimMission,
    this.claimingMissionId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Misi Yang Aktif',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Text(
              'Reset dalam 9 jam',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var index = 0; index < missions.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          RewardMissionCard(
            mission: missions[index],
            isClaiming: claimingMissionId == missions[index].id,
            onClaim: () => onClaimMission(missions[index]),
          ),
        ],
      ],
    );
  }
}

class RewardMissionCard extends StatelessWidget {
  final RewardMission mission;
  final bool isClaiming;
  final VoidCallback onClaim;

  const RewardMissionCard({
    super.key,
    required this.mission,
    required this.isClaiming,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  mission.title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/image/icon_footer4.png',
                    width: 16,
                    height: 16,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${mission.rewardCoin}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: mission.progress,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${mission.progressValue}/${mission.targetValue}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (mission.isClaimed)
                const Text(
                  'Diklaim',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (mission.isCompleted)
                TextButton(
                  onPressed: isClaiming ? null : onClaim,
                  child: Text(
                    isClaiming ? '...' : 'Klaim',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
