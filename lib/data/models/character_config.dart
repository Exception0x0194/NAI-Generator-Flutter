import 'dart:math';

import 'package:nai_casrand/data/models/prompt_config.dart';

class CharacterPromptResult {
  Point<int> center;
  NestedPrompt prompt;
  String uc;

  CharacterPromptResult({
    required this.center,
    required this.prompt,
    required this.uc,
  });
}

class CharacterConfig {
  List<Point<int>> positions;
  PromptConfig positivePromptConfig;
  String negativePrompt;
  bool enabled;

  CharacterConfig({
    required this.positions,
    required this.positivePromptConfig,
    required this.negativePrompt,
    required this.enabled,
  });

  CharacterPromptResult getPrompt() {
    final random = Random();
    final promptResult = positivePromptConfig.getPrmpts();
    final Point<int> positionAsInt;
    if (positions.isNotEmpty) {
      positionAsInt = positions[random.nextInt(positions.length)];
    } else {
      positionAsInt = const Point(0, 0);
    }
    return CharacterPromptResult(
      center: positionAsInt,
      prompt: promptResult,
      uc: negativePrompt,
    );
  }

  factory CharacterConfig.fromEmpty() {
    return CharacterConfig(
      positions: [],
      positivePromptConfig: PromptConfig(strs: [], prompts: []),
      negativePrompt: '',
      enabled: true,
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
      negativePrompt: json['negativePrompt'] ?? '',
      enabled: json['enabled'] ?? true,
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
      'enabled': enabled,
    };
  }
}
