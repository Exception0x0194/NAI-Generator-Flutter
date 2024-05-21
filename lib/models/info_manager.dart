// 文件路径：lib/models/info_manager.dart
import 'prompt_config.dart';

class InfoManager {
  static final InfoManager _instance = InfoManager._internal();

  factory InfoManager() {
    return _instance;
  }
  InfoManager._internal() {
    loadInitialConfig();
  }

  String? apiKey;
  String? proxySettings;
  late PromptConfig config;

  Future<void> loadInitialConfig() async {
    config = PromptConfig.fromJson({}, 0);
  }

  void loadPrompts(Map<String, dynamic> jsonData) {
    config = PromptConfig.fromJson(jsonData, 0);
  }

  void setApiKey(String key) {
    apiKey = key;
  }

  void setProxySettings(String proxy) {
    proxySettings = proxy;
  }
}
