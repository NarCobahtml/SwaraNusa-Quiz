import 'package:audioplayers/audioplayers.dart';

class QuizMediaService {
  const QuizMediaService();

  bool isNetworkUrl(String value) {
    final normalized = value.toLowerCase();
    return normalized.startsWith('http://') || normalized.startsWith('https://');
  }

  Source audioSource(String mediaUrl) {
    if (isNetworkUrl(mediaUrl)) {
      return UrlSource(mediaUrl);
    }
    return AssetSource(assetAudioPath(mediaUrl));
  }

  String assetAudioPath(String value) {
    const assetPrefix = 'assets/';
    if (value.startsWith(assetPrefix)) {
      return value.substring(assetPrefix.length);
    }
    return value;
  }
}
