import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/backend_services.dart';

class GamelanMinigameController extends GetxController {
  final AudioPlayer _audioPlayer;

  GamelanMinigameController({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer();

  static const List<String> fallbackNotes = [
    'audio/n1.mp3',
    'audio/n2.mp3',
    'audio/n3.mp3',
    'audio/n4.mp3',
    'audio/n5.mp3',
    'audio/n6.mpeg',
  ];

  late final List<String> noteSources = _readNoteSources(Get.arguments);
  late final String instrumentId = _readInstrumentId(Get.arguments);

  int get noteCount => noteSources.length;

  final activePotIndex = RxnInt();
  final Set<int> _playedIndexes = <int>{};
  bool _isDisposed = false;
  bool _masteryRecorded = false;
  bool _playMissionRecorded = false;
  int _pressToken = 0;

  Future<void> playNote(int index) async {
    if (index < 0 || index >= noteSources.length) return;

    _playedIndexes.add(index);
    _recordPlayMissionIfNeeded();
    _recordMasteryIfReady();

    final currentPressToken = ++_pressToken;
    activePotIndex.value = index;
    Future<void>.delayed(const Duration(milliseconds: 160), () {
      if (!_isDisposed && _pressToken == currentPressToken) {
        activePotIndex.value = null;
      }
    });

    try {
      await _audioPlayer.stop();
      final source = noteSources[index];
      if (_isNetworkSource(source)) {
        await _audioPlayer.play(UrlSource(source));
      } else {
        await _audioPlayer.play(AssetSource(_assetSourcePath(source)));
      }
    } catch (error) {
      debugPrint('Error playing sound: $error');
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _audioPlayer.dispose();
    super.onClose();
  }

  List<String> _readNoteSources(Object? arguments) {
    if (arguments is Map && arguments['noteSources'] is Iterable) {
      final sources = (arguments['noteSources'] as Iterable)
          .map((source) => source.toString())
          .where((source) => source.isNotEmpty)
          .toList(growable: false);
      if (sources.isNotEmpty) return sources;
    }

    return fallbackNotes;
  }

  String _readInstrumentId(Object? arguments) {
    if (arguments is Map) {
      return arguments['instrumentId']?.toString() ?? '';
    }
    return '';
  }

  void _recordMasteryIfReady() {
    if (_masteryRecorded ||
        instrumentId.isEmpty ||
        noteCount <= 0 ||
        _playedIndexes.length < noteCount) {
      return;
    }
    _masteryRecorded = true;
    unawaited(InstrumentMasteryService.instance.markMastered(instrumentId));
  }

  void _recordPlayMissionIfNeeded() {
    if (_playMissionRecorded) return;
    _playMissionRecorded = true;
    unawaited(MissionService.instance.incrementProgress('play_game', by: 1));
  }

  bool _isNetworkSource(String source) {
    return source.startsWith('http://') || source.startsWith('https://');
  }

  String _assetSourcePath(String source) {
    return source.startsWith('assets/')
        ? source.replaceFirst('assets/', '')
        : source;
  }
}
