import 'dart:math';

import 'package:nai_casrand/data/models/prompt_config.dart';

class CharacterPromptResult {
  Point<double> center;
  String caption;
  String uc;
  String comment;

  CharacterPromptResult({
    required this.center,
    required this.caption,
    required this.uc,
    required this.comment,
  });
}

class CharacterConfig {
  List<Point<int>> positions;
  PromptConfig positivePromptConfig;
  String negativePrompt;

  CharacterConfig({
    required this.positions,
    required this.positivePromptConfig,
    required this.negativePrompt,
  });

  CharacterPromptResult getPrompt() {
    final random = Random();
    final promptResult = positivePromptConfig.getPrompt();
    final Point<int> positionAsInt;
    const Map<int, double> mapping = {
      0: 0.0,
      1: 0.1,
      2: 0.3,
      3: 0.5,
      4: 0.7,
      5: 0.9
    };
    if (positions.isEmpty) {
      positionAsInt = positions[random.nextInt(positions.length)];
    } else {
      positionAsInt = const Point(0, 0);
    }
    final positionAsDouble =
        Point(mapping[positionAsInt.x]!, mapping[positionAsInt.y]!);
    return CharacterPromptResult(
      center: positionAsDouble,
      caption: promptResult.prompt,
      uc: negativePrompt,
      comment: promptResult.comment,
    );
  }

  factory CharacterConfig.fromJson(Map<String, dynamic> json) {
    final positionsJson = json['positions'] as List<dynamic>;
    final positions = positionsJson.map((position) {
      final point = position as Map<String, dynamic>;
      return Point<int>(point['x'], point['y']);
    }).toList();

    return CharacterConfig(
      positions: positions,
      positivePromptConfig: PromptConfig.fromJson(json['positivePromptConfig']),
      negativePrompt: json['negativePrompt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positions': positions.map((point) {
        return {
          'x': point.x,
          'y': point.y,
        };
      }).toList(),
      'positivePromptConfig': positivePromptConfig.toJson(),
      'negativePrompt': negativePrompt,
    };
  }
}
