import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class GamelanMinigameController extends GetxController {
  final AudioPlayer _audioPlayer;

  GamelanMinigameController({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer();

  static const List<String> notes = [
    'audio/n1.mp3',
    'audio/n2.mp3',
    'audio/n3.mp3',
    'audio/n4.mp3',
    'audio/n5.mp3',
    'audio/n6.mpeg',
  ];

  final activePotIndex = RxnInt();
  bool _isDisposed = false;

  Future<void> playNote(int index) async {
    activePotIndex.value = index;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(notes[index]));
    } catch (error) {
      debugPrint('Error playing sound: $error');
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!_isDisposed) {
      activePotIndex.value = null;
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _audioPlayer.dispose();
    super.onClose();
  }
}
