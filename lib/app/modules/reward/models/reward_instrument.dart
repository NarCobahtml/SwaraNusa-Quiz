import 'package:swaranusaquiz/app/data/models/backend_models.dart';

class RewardInstrument {
  final String id;
  final String imageSource;
  final String name;
  final String region;
  final List<String> noteSources;
  final int price;
  final bool opensMinigame;

  const RewardInstrument({
    required this.id,
    required this.imageSource,
    required this.name,
    required this.region,
    this.noteSources = const [],
    this.price = 0,
    this.opensMinigame = false,
  });

  factory RewardInstrument.fromDoc(InstrumentDoc doc) {
    return RewardInstrument(
      id: doc.id,
      imageSource: doc.imageUrl,
      name: doc.name,
      region: doc.region,
      noteSources: doc.noteUrls,
      price: doc.price,
      opensMinigame: doc.opensMinigame,
    );
  }
}
