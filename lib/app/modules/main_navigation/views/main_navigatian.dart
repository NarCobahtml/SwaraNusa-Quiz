import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/home/views/home_page.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/views/leaderboard.dart';
import 'package:swaranusaquiz/app/modules/main_navigation/controllers/main_navigation_controller.dart';
import 'package:swaranusaquiz/app/modules/mode/views/mode_page.dart';
import 'package:swaranusaquiz/app/modules/profile/views/profil.dart';
import 'package:swaranusaquiz/app/modules/reward/views/reward_page.dart';

class MainNavigation extends StatelessWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  static const List<String> footerIcons = [
    'assets/image/icon_footer1.png',
    'assets/image/icon_footer2.png',
    'assets/image/icon_footer4.png',
    'assets/image/icon_footer5.png',
  ];

  static const List<String> navLabels = [
    'Beranda',
    'Papan Skor',
    'Hadiah',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainNavigationController>();
    if (initialIndex != controller.bottomNavIndex.value) {
      controller.selectTab(initialIndex);
    }

    final List<Widget> pages = [
      HomePage(onNavigateToMode: () => controller.selectTab(4)),
      const LeaderboardScreen(showNavbar: false),
      const RewardPage(),
      ProfileScreen(
        showNavbar: false,
        onRewardTap: () => controller.selectTab(2),
      ),
      const ModePage(),
    ];

    return Obx(() {
      final bottomNavIndex = controller.bottomNavIndex.value;
      final pressedIndex = controller.pressedIndex.value;
      final isFabPressed = controller.isFabPressed.value;

      return Scaffold(
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: pages[bottomNavIndex < pages.length ? bottomNavIndex : 0],
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        floatingActionButton: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withAlpha(100),
                    AppColors.gold.withAlpha(50),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: bottomNavIndex == 4
                      ? AppColors.gold
                      : AppColors.gold.withAlpha(100),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onHighlightChanged: controller.setFabPressed,
                    onTap: () => controller.selectTab(4),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AnimatedScale(
                        scale: isFabPressed ? 0.85 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                        child: Image.asset(
                          'assets/image/icon_footer3.png',
                          color: bottomNavIndex == 4
                              ? AppColors.gold
                              : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          itemCount: footerIcons.length,
          tabBuilder: (int index, bool isActive) {
            final color = isActive ? AppColors.gold : AppColors.textLight;

            return Listener(
              onPointerDown: (_) => controller.setPressedIndex(index),
              onPointerUp: (_) => controller.setPressedIndex(null),
              onPointerCancel: (_) => controller.setPressedIndex(null),
              child: AnimatedScale(
                scale: pressedIndex == index ? 0.85 : 1.0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      footerIcons[index],
                      color: color,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      navLabels[index],
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          activeIndex: bottomNavIndex >= 4 ? -1 : bottomNavIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          leftCornerRadius: 20,
          rightCornerRadius: 20,
          backgroundColor: AppColors.primary,
          splashColor: AppColors.transparent,
          splashRadius: 0,
          splashSpeedInMilliseconds: 0,
          onTap: controller.selectTab,
        ),
      );
    });
  }
}
