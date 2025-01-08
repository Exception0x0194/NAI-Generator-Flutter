import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nai_casrand/data/models/character_config.dart';
import 'package:nai_casrand/data/models/i2i_config.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/data/models/prompt_config.dart';
import 'package:nai_casrand/models/vibe_config.dart';

class ConfigService {
  late PromptConfig rootPromptConfig;
  late List<CharacterConfig> characterConfigList;

  late ParamConfig paramConfig;

  I2IConfig i2iConfig = I2IConfig();
  List<VibeConfig> vibeConfigList = [];

  Future loadConfig() async {
    Map<String, dynamic> jsonData =
        json.decode(await rootBundle.loadString('assets/json/example.json'));

    rootPromptConfig = PromptConfig.fromJson(jsonData['prompt_config']);
    final characterConfigJsonList =
        jsonData['character_config'] as List<dynamic>;
    characterConfigList = characterConfigJsonList.map((configJson) {
      return CharacterConfig.fromJson(configJson);
    }).toList();
    paramConfig = ParamConfig.fromJson(jsonData['param_config']);
  }
}
