import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class ProfileThemeMenu extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onLightModeChanged;

  const ProfileThemeMenu({
    super.key,
    required this.isDarkMode,
    required this.onLightModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(80),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isDarkMode
                          ? Icons.nightlight_round
                          : Icons.wb_sunny,
                      key: ValueKey<bool>(isDarkMode),
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isDarkMode ? 'Dark Mode' : 'Light Mode',
                    key: ValueKey<bool>(isDarkMode),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Switch(
              value: !isDarkMode,
              onChanged: onLightModeChanged,
              activeThumbColor: AppColors.primary,
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.secondary;
                }
                return AppColors.divider;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
