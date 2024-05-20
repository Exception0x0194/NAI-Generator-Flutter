// 文件路径：lib/models/info_manager.dart
import 'prompt_config.dart';

class InfoManager {
  static final InfoManager _instance = InfoManager._internal();

  factory InfoManager() {
    return _instance;
  }

  InfoManager._internal();

  PromptsGenerator? promptsGenerator;
  String? apiKey;
  String? proxySettings;

  void loadPrompts(Map<String, dynamic> jsonData) {
    promptsGenerator = PromptsGenerator(jsonData);
  }

  void setApiKey(String key) {
    apiKey = key;
  }

  void setProxySettings(String proxy) {
    proxySettings = proxy;
  }
}
