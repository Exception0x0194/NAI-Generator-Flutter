import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nai_casrand/data/models/character_config.dart';

class CharacterConfigViewmodel extends ChangeNotifier {
  CharacterConfig config;

  CharacterConfigViewmodel({required this.config});

  String getPositionsTexts() {
    const Map<int, String> xMapping = {
      1: 'A',
      2: 'B',
      3: 'C',
      4: 'D',
      5: 'E',
    };
    List<String> ret = [];
    for (final point in config.positions) {
      String pt = '';
      pt += xMapping[point.x] ?? '';
      pt += point.y.toString();
      ret.add(pt);
    }

    return ret.join(', ');
  }

  void setNegativePrompt(String value) {
    config.negativePrompt = value;
    notifyListeners();
  }

  void switchPosition(Point<int> pt) {
    if (config.positions.contains(pt)) {
      config.positions.remove(pt);
    } else {
      config.positions.add(pt);
    }
    notifyListeners();
  }
}
