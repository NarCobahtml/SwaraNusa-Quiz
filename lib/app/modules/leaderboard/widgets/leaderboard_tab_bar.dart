import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/season_service.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class LeaderboardTabBar extends StatelessWidget {
  const LeaderboardTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        width: 253,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Get.isRegistered<SeasonService>()
            ? Obx(
                () => _LeaderboardTabLabel(
                  text: SeasonService.to.activeSeasonTitle.value,
                ),
              )
            : const _LeaderboardTabLabel(text: 'Season'),
      ),
    );
  }
}

class _LeaderboardTabLabel extends StatelessWidget {
  final String text;

  const _LeaderboardTabLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final label = text.trim().isEmpty ? 'Season' : text.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
