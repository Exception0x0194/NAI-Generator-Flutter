import 'package:flutter/foundation.dart';

import '../../../data/models/vibe_config_v4.dart';

class VibeConfigV4Viewmodel extends ChangeNotifier {
  VibeConfigV4 config;

  VibeConfigV4Viewmodel({required this.config});

  String get fileName => config.fileName;
  Uint8List? get imageBytes => config.imageBytes;
  double get referenceStrength => config.referenceStrength;

  setReferenceStrength(double value) {
    config.referenceStrength = value;
    notifyListeners();
  }
}
