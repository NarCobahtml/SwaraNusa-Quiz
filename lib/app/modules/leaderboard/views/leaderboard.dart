import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/leaderboard_user.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/controllers/leaderboard_controller.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/widgets/leaderboard_header.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/widgets/leaderboard_list.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/widgets/leaderboard_podium.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/widgets/leaderboard_tab_bar.dart';

class LeaderboardScreen extends StatelessWidget {
  final int? currentUserId;
  final List<LeaderboardUser> leaderboardData;
  final bool showNavbar;

  const LeaderboardScreen({
    super.key,
    this.currentUserId,
    required this.leaderboardData,
    this.showNavbar = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LeaderboardController>()
        ? Get.find<LeaderboardController>()
        : LeaderboardController(leaderboardData);
    final topPadding = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        SizedBox(height: topPadding + 16),
        const LeaderboardHeader(),
        const SizedBox(height: 20),
        const LeaderboardTabBar(),
        const SizedBox(height: 24),
        LeaderboardPodium(users: controller.topUsers),
        const SizedBox(height: 20),
        Expanded(
          child: LeaderboardList(
            users: controller.remainingUsers,
            currentUserId: currentUserId,
          ),
        ),
      ],
    );
  }
}
