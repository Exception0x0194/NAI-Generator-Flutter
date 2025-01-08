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
    const Map<int, String> yMapping = {
      1: '1',
      2: '2',
      3: '3',
      4: '4',
      5: '5',
    };
    List<String> ret = [];
    for (final point in config.positions) {
      String pt = '';
      pt += xMapping[point.x] ?? '';
      pt += yMapping[point.y] ?? '';
      ret.add(pt);
    }

    return ret.join(', ');
  }

  void setNegativePrompt(String value) {
    config.negativePrompt = value;
    notifyListeners();
  }
}
