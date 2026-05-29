import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/user_service.dart';
import 'package:swaranusaquiz/app/modules/home/controllers/home_controller.dart';
import 'package:swaranusaquiz/app/modules/home/widgets/continue_playing_section.dart';
import 'package:swaranusaquiz/app/modules/home/widgets/daily_missions_section.dart';
import 'package:swaranusaquiz/app/modules/home/widgets/home_leaderboard_section.dart';
import 'package:swaranusaquiz/app/modules/home/widgets/home_profile_card.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onNavigateToMode;

  const HomePage({super.key, this.onNavigateToMode});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: topPadding + 16,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Obx agar reaktif saat UserService selesai load
                Obx(() {
                  // Akses currentUser agar widget rebuild saat data berubah
                  UserService.to.currentUser.value;
                  return HomeProfileCard(profile: controller.profile);
                }),
                const SizedBox(height: 24),
                ContinuePlayingSection(
                  onTap: onNavigateToMode ?? controller.openMode,
                ),
                const SizedBox(height: 24),
                Obx(
                  () => DailyMissionsSection(
                    missions: controller.dailyMissions,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => HomeLeaderboardSection(
                    entries: controller.leaderboardEntries.toList(
                      growable: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
