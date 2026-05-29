import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/reward/models/unlockable_instrument.dart';

class UnlockInstrumentCard extends StatelessWidget {
  final UnlockableInstrument instrument;
  final VoidCallback onPurchase;
  final bool isPurchasing;

  const UnlockInstrumentCard({
    super.key,
    required this.instrument,
    required this.onPurchase,
    this.isPurchasing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            clipBehavior: Clip.antiAlias,
            child: _UnlockInstrumentImage(source: instrument.imageSource),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instrument.name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: isPurchasing ? null : onPurchase,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: const BorderSide(color: AppColors.gold, width: 1),
              ),
            ),
            child: isPurchasing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gold,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        '${instrument.price}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Image.asset(
                        'assets/image/icon_footer4.png',
                        width: 16,
                        height: 16,
                        color: AppColors.gold,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _UnlockInstrumentImage extends StatelessWidget {
  final String source;

  const _UnlockInstrumentImage({required this.source});

  @override
  Widget build(BuildContext context) {
    final normalizedSource = source.trim();
    if (normalizedSource.isEmpty) return const _UnlockInstrumentFallbackIcon();

    if (normalizedSource.startsWith('http://') ||
        normalizedSource.startsWith('https://')) {
      return Image.network(
        normalizedSource,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const _UnlockInstrumentFallbackIcon(),
      );
    }

    return Image.asset(
      _assetPath(normalizedSource),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const _UnlockInstrumentFallbackIcon(),
    );
  }

  String _assetPath(String value) {
    if (value.startsWith('assets/')) return value;
    if (value.startsWith('image/')) return 'assets/$value';
    return 'assets/image/$value';
  }
}

class _UnlockInstrumentFallbackIcon extends StatelessWidget {
  const _UnlockInstrumentFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Icon(
        Icons.lock_open_rounded,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}
