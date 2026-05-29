import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/reward/models/reward_instrument.dart';

class InstrumentCollectionSection extends StatelessWidget {
  final List<RewardInstrument> instruments;
  final ValueChanged<RewardInstrument> onInstrumentTap;

  const InstrumentCollectionSection({
    super.key,
    required this.instruments,
    required this.onInstrumentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Koleksi Instrumen',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: instruments.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final instrument = instruments[index];
              return GestureDetector(
                onTap: () => onInstrumentTap(instrument),
                child: InstrumentCard(instrument: instrument),
              );
            },
          ),
        ),
      ],
    );
  }
}

class InstrumentCard extends StatelessWidget {
  final RewardInstrument instrument;

  const InstrumentCard({super.key, required this.instrument});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: _InstrumentImage(source: instrument.imageSource),
          ),
          const SizedBox(height: 8),
          Text(
            instrument.name,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            instrument.region,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InstrumentImage extends StatelessWidget {
  final String source;

  const _InstrumentImage({required this.source});

  @override
  Widget build(BuildContext context) {
    final normalizedSource = source.trim();
    if (normalizedSource.isEmpty) return const _InstrumentFallbackIcon();

    if (normalizedSource.startsWith('http://') ||
        normalizedSource.startsWith('https://')) {
      return Image.network(
        normalizedSource,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const _InstrumentFallbackIcon(),
      );
    }

    return Image.asset(
      _assetPath(normalizedSource),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const _InstrumentFallbackIcon(),
    );
  }

  String _assetPath(String value) {
    if (value.startsWith('assets/')) return value;
    if (value.startsWith('image/')) return 'assets/$value';
    return 'assets/image/$value';
  }
}

class _InstrumentFallbackIcon extends StatelessWidget {
  const _InstrumentFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Icon(
        Icons.music_note_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }
}
