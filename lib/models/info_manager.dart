import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'dart:js_interop';
import 'dart:math';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'prompt_config.dart';
import 'param_config.dart';
import 'downloads.dart';

class InfoManager {
  static final InfoManager _instance = InfoManager._internal();

  factory InfoManager() {
    return _instance;
  }
  InfoManager._internal();

  String apiKey = 'pst-abcd';

  PromptConfig promptConfig = PromptConfig();
  ParamConfig paramConfig = ParamConfig();

  Map<String, dynamic> toJson() {
    return {
      "api_key": apiKey,
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
    return true;
  }

  Map<String, String> get headers => {
        "authorization": "Bearer $apiKey",
        "referer": "https://novelai.net",
        "user-agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"
      };

  Map<String, dynamic> getRequestData() {
    var pickedPrompts = promptConfig.pickPromptsFromConfig();
    return {
      "body": {
        "input": pickedPrompts['prompt'],
        "model": "nai-diffusion-3",
        "action": "generate",
        "parameters": paramConfig.toJson(),
      },
      "comment": pickedPrompts['comment']
    };
  }

  Future<Map<String, dynamic>> generateImage() async {
    var url = Uri.parse('https://image.novelai.net/ai/generate-image');
    var data = getRequestData();
    var response =
        await http.post(url, headers: headers, body: json.encode(data['body']));
    var bytes = response.bodyBytes;
    try {
      var archive = ZipDecoder().decodeBytes(bytes);
      for (var file in archive) {
        if (file.name == "image_0.png") {
          var filename = generateRandomFileName() + '.png';
          var imageBytes = file.content as List<int>;
          await saveBlob(imageBytes, filename);
          return {'status': 'success', 'comment': data['comment']};
        }
      }
      return {'status': 'failed', 'error': utf8.decode(response.bodyBytes)};
    } catch (e) {
      return {'status': 'failed', 'error': e};
    }
  }
}
