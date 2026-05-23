import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/utils/number_formatter.dart';

class CoinBalanceBadge extends StatelessWidget {
  final int balance;

  const CoinBalanceBadge({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            NumberFormatter.compactThousands(balance),
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
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
