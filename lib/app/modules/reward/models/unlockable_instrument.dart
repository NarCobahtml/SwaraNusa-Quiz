import 'package:swaranusaquiz/app/data/models/backend_models.dart';

class UnlockableInstrument {
  final String id;
  final String imageSource;
  final String name;
  final int price;

  const UnlockableInstrument({
    required this.id,
    required this.imageSource,
    required this.name,
    required this.price,
  });

  factory UnlockableInstrument.fromDoc(InstrumentDoc doc) {
    return UnlockableInstrument(
      id: doc.id,
      imageSource: doc.imageUrl,
      name: doc.name,
      price: doc.price,
    );
  }
}
