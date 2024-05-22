// 文件路径：lib/models/info_manager.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'prompt_config.dart';
import 'param_config.dart';

class InfoManager {
  static final InfoManager _instance = InfoManager._internal();

  factory InfoManager() {
    return _instance;
  }
  InfoManager._internal() ;

  String? apiKey;
  String? proxy;

  PromptConfig promptConfig = PromptConfig();
  ParamConfig paramConfig = ParamConfig();

  Map<String, dynamic> toJson(){
    return {"api_key": apiKey, "proxy":proxy, "prompt_config":promptConfig.toJson(), "param_config":paramConfig.toJson()};
  }

  bool fromJson(Map<String, dynamic> jsonConfig) {
    try {
      PromptConfig tryPromptConfig = PromptConfig.fromJson(jsonConfig['prompt_config'], 0);
      ParamConfig tryParamConfig = ParamConfig.fromJson(jsonConfig['param_config']);
      promptConfig = tryPromptConfig;
      paramConfig = tryParamConfig;
    } catch (e) {
      return false;
    }
    apiKey = jsonConfig['api_key'];
    proxy = jsonConfig['proxy'];
    return true;
  }
}
