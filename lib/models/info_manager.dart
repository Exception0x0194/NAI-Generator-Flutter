import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'dart:js_interop';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'prompt_config.dart';
import 'param_config.dart';

class InfoManager {
  static final InfoManager _instance = InfoManager._internal();

  factory InfoManager() {
    return _instance;
  }
  InfoManager._internal();

  String apiKey = 'pst-abcd';
  String proxy = 'http://localhost:9999';

  PromptConfig promptConfig = PromptConfig();
  ParamConfig paramConfig = ParamConfig();

  Map<String, dynamic> toJson() {
    return {
      "api_key": apiKey,
      "proxy": proxy,
      "prompt_config": promptConfig.toJson(),
      "param_config": paramConfig.toJson()
    };
  }

  bool fromJson(Map<String, dynamic> jsonConfig) {
    try {
      PromptConfig tryPromptConfig =
          PromptConfig.fromJson(jsonConfig['prompt_config'], 0);
      ParamConfig tryParamConfig =
          ParamConfig.fromJson(jsonConfig['param_config']);
      promptConfig = tryPromptConfig;
      paramConfig = tryParamConfig;
    } catch (e) {
      return false;
    }
    apiKey = jsonConfig['api_key'];
    proxy = jsonConfig['proxy'];
    return true;
  }

  Map<String, String> get headers => {
        "authorization": "Bearer $apiKey",
        "referer": "https://novelai.net",
        "user-agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"
      };

  Map<String, dynamic> getRequestBody() {
    return {
      "input": promptConfig.pickPromptsFromConfig()['prompt'],
      "model": "nai-diffusion-3",
      "action": "generate",
      "parameters": paramConfig.toJson(),
    };
  }

  Future<Map<String, dynamic>> generateImage() async {
    var url = Uri.parse('https://image.novelai.net/ai/generate-image');
    var response = await http.post(url,
        headers: headers, body: json.encode(getRequestBody()));
    var bytes = response.bodyBytes;
    print(response);
    try {
      var archive = ZipDecoder().decodeBytes(bytes);
      for (var file in archive) {
        if (file.name == "image_0.png") {
          print(file.name);
          var imageBytes = file.content as List<int>;
          return {'status': 'success', 'bytes': imageBytes};
        }
      }
      return {'status': 'failed', 'error': utf8.decode(response.bodyBytes)};
    } catch (e) {
      return {'status': 'failed', 'error': e};
    }
  }
}
