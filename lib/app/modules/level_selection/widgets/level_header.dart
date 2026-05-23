import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class LevelHeader extends StatelessWidget {
  final String title;

  const LevelHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final didPop = await Navigator.of(context).maybePop();
                if (!didPop) {
                  Get.offNamed(AppRoutes.mainNavigation);
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.textDark,
                  size: 28,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
