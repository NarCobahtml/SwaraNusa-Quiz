import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/reward/controllers/reward_controller.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class DailyLoginBonusCard extends StatelessWidget {
  const DailyLoginBonusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RewardController>();

    return Obx(() {
      final claimed = controller.dailyAlreadyClaimed.value;
      final loading = controller.isClaimingDaily.value;

      return GestureDetector(
        onTap: (claimed || loading) ? null : controller.claimDailyLogin,
        child: AnimatedOpacity(
          opacity: claimed ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: claimed
                  ? Border.all(color: AppColors.divider)
                  : Border.all(color: AppColors.gold.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/image/icon_calendar.png',
                  width: 48,
                  height: 48,
                  color: claimed ? AppColors.textMuted : AppColors.gold,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonus Login Harian',
                        style: TextStyle(
                          color: claimed
                              ? AppColors.textMuted
                              : AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        claimed
                            ? 'Sudah diklaim hari ini. Kembali besok!'
                            : 'Klaim bonus harianmu untuk menjaga rutinitas!',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (loading)
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gold,
                    ),
                  )
                else if (claimed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check, color: AppColors.textMuted, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Diklaim',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _DailyBonusAmount(),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _DailyBonusAmount extends StatelessWidget {
  const _DailyBonusAmount();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.gold, width: 1),
      ),
      child: Row(
        children: [
          const Text(
            '+100',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(
            'assets/image/icon_footer4.png',
            width: 16,
            height: 16,
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }
}
