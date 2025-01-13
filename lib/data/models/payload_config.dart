import 'package:nai_casrand/data/models/character_config.dart';
import 'package:nai_casrand/data/models/i2i_config.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/data/models/prompt_config.dart';
import 'package:nai_casrand/data/models/settings.dart';
import 'package:nai_casrand/data/models/vibe_config.dart';

class PayloadResult {
  final String comment;
  final Map<String, dynamic> payload;

  const PayloadResult({
    required this.comment,
    required this.payload,
  });
}

const Map<int, String> xMapping = {
  0: 'X',
  1: 'A',
  2: 'B',
  3: 'C',
  4: 'D',
  5: 'E',
};

const Map<int, double> doubleMapping = {
  0: 0.0,
  1: 0.1,
  2: 0.3,
  3: 0.5,
  4: 0.7,
  5: 0.9
};

class PayloadConfig {
  PromptConfig rootPromptConfig;
  List<CharacterConfig> characterConfigList;

  ParamConfig paramConfig;

  Settings settings;

  I2IConfig i2iConfig = I2IConfig();
  List<VibeConfig> vibeConfigList = [];

  PayloadConfig({
    required this.rootPromptConfig,
    required this.characterConfigList,
    required this.paramConfig,
    required this.settings,
  });

  PayloadResult getPayload() {
    final paramPayload = paramConfig.getPayload();

    final basePromptResult = rootPromptConfig.getPrompt();
    String payloadComment = basePromptResult.comment;
    final configPromptResultList =
        characterConfigList.map((elem) => elem.getPrompt()).toList();

    // Character prompts
    final characterPrompts = [];
    final v4CharPosCaptions = [];
    final v4CharNegCaptions = [];
    for (final (index, result) in configPromptResultList.indexed) {
      final posAsString = '${xMapping[result.center.x]}${result.center.y}';
      final posAsDouble = {
        'x': doubleMapping[result.center.x]!,
        'y': doubleMapping[result.center.y]!,
      };
      payloadComment +=
          '\nCharacter#$index at $posAsString:\n${result.comment}';
      characterPrompts.add({
        'prompt': result.caption,
        'uc': result.uc,
        'center': posAsDouble,
      });
      v4CharPosCaptions.add({
        'char_caption': result.caption,
        'centers': posAsDouble,
      });
      v4CharNegCaptions.add({
        'char_caption': result.uc,
        'centers': posAsDouble,
      });
    }
    final v4Prompt = {
      'caption': {
        'base_caption': basePromptResult.prompt,
        'char_captions': v4CharPosCaptions,
      },
      'use_coords': !paramConfig.autoPosition,
      'use_order': true,
    };
    final v4NegPrompt = {
      'caption': {
        'base_caption': paramConfig.negativePrompt,
        'char_captions': v4CharNegCaptions,
      },
      'use_coords': !paramConfig.autoPosition,
      'use_order': true,
    };
    paramPayload['v4_prompt'] = v4Prompt;
    paramPayload['v4_negative_prompt'] = v4NegPrompt;
    paramPayload['characterPrompts'] = characterPrompts;

    return PayloadResult(
      comment: payloadComment,
      payload: {
        'input': basePromptResult.prompt,
        'model': paramConfig.model,
        'action': 'generation',
        'parameters': paramPayload,
      },
    );
  }

  Map<String, String> getHeaders() {
    return {
      "authorization": "Bearer ${settings.apiKey}",
      "referer": "https://novelai.net",
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0"
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "prompt_config": rootPromptConfig.toJson(),
      "character_config":
          characterConfigList.map((elem) => elem.toJson()).toList(),
      "param_config": paramConfig.toJson(),
      "settings": settings.toJson()
    };
  }

  factory PayloadConfig.fromJson(Map<String, dynamic> jsonData) {
    final jsonCharacterList = jsonData.containsKey('character_config')
        ? jsonData['character_config'] as List<dynamic>
        : [];
    final characterList = jsonCharacterList.map((configJson) {
      return CharacterConfig.fromJson(configJson);
    }).toList();
    return PayloadConfig(
      rootPromptConfig: PromptConfig.fromJson(jsonData['prompt_config']),
      characterConfigList: characterList,
      paramConfig: ParamConfig.fromJson(jsonData['param_config'] ?? {}),
      settings: Settings.fromJson(jsonData['settings'] ?? {}),
    );
  }

  void loadJson(Map<String, dynamic> jsonData) {
    final jsonCharacterList = jsonData.containsKey('character_config')
        ? jsonData['character_config'] as List<dynamic>
        : [];
    final characterList = jsonCharacterList.map((configJson) {
      return CharacterConfig.fromJson(configJson);
    }).toList();
    rootPromptConfig = PromptConfig.fromJson(jsonData['prompt_config']);
    characterConfigList = characterList;
    paramConfig = ParamConfig.fromJson(jsonData['param_config'] ?? {});
    settings = Settings.fromJson(jsonData['settings'] ?? {});
  }
}
