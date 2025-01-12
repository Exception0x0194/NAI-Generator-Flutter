import 'package:flutter/material.dart';
import 'package:nai_casrand/data/models/vibe_config.dart';

class VibeViewmodel extends ChangeNotifier {
  final VibeConfig config;

  VibeViewmodel({required this.config});

  void setInfoExtracted(double value) {
    config.infoExtracted = value;
    notifyListeners();
  }

  void setReferenceStrength(double value) {
    config.infoExtracted = value;
    notifyListeners();
  }
}
