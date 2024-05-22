// 文件路径：lib/models/info_manager.dart
import 'prompt_config.dart';
import 'param_config.dart';

class InfoManager {
  static final InfoManager _instance = InfoManager._internal();

  factory InfoManager() {
    return _instance;
  }
  InfoManager._internal() {
    loadInitialConfig();
  }

  String? apiKey = 'pst-abc';
  String? proxy;

  late PromptConfig promptConfig;
  late ParamConfig paramConfig;

  Future<void> loadInitialConfig() async {
    promptConfig = PromptConfig.fromJson({}, 0);
    paramConfig = ParamConfig();
  }

  void loadPrompts(Map<String, dynamic> jsonData) {
    promptConfig = PromptConfig.fromJson(jsonData, 0);
  }
}
