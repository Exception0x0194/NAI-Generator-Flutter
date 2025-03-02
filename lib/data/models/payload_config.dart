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
  List<PromptConfig> savedPromptConfigList;

  ParamConfig paramConfig;

  Settings settings;

  I2IConfig i2iConfig = I2IConfig();
  List<VibeConfig> vibeConfigList = [];

  PayloadConfig({
    required this.rootPromptConfig,
    required this.characterConfigList,
    required this.savedPromptConfigList,
    required this.paramConfig,
    required this.settings,
  });

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
      "saved_config":
          savedPromptConfigList.map((elem) => elem.toJson()).toList(),
      "param_config": paramConfig.toJson(),
      "settings": settings.toJson()
    };
  }

  factory PayloadConfig.fromJson(Map<String, dynamic> jsonData) {
    final jsonCharacterList = jsonData.containsKey('character_config')
        ? jsonData['character_config'] as List<dynamic>
        : [];
    final jsonSavedPromptList = jsonData.containsKey('saved_config')
        ? jsonData['saved_config'] as List<dynamic>
        : [];
    final characterList = jsonCharacterList
        .map((configJson) => CharacterConfig.fromJson(configJson))
        .toList();
    final savedList = jsonSavedPromptList
        .map((configJson) => PromptConfig.fromJson(configJson))
        .toList();
    return PayloadConfig(
      rootPromptConfig: PromptConfig.fromJson(jsonData['prompt_config']),
      characterConfigList: characterList,
      savedPromptConfigList: savedList,
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
