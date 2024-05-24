import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'prompt_config.dart';
import 'param_config.dart';
import 'utils.dart';

class InfoManager with ChangeNotifier {
  static final InfoManager _instance = InfoManager._internal();

  factory InfoManager() {
    return _instance;
  }
  InfoManager._internal();

  String apiKey = 'pst-abcd';
  late PromptConfig promptConfig = PromptConfig();
  ParamConfig paramConfig = ParamConfig();

  String log = '';
  Image? img;
  bool isRequesting = false;
  bool isGenerating = false;

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

  Future<void> generateImage() async {
    if (isRequesting) {
      return;
    }
    log += 'Requesting...';
    isRequesting = true;
    notifyListeners();

    var url = Uri.parse('https://image.novelai.net/ai/generate-image');
    var data = getRequestData();

    try {
      var response = await http.post(url,
          headers: headers, body: json.encode(data['body']));
      var bytes = response.bodyBytes;
      var archive = ZipDecoder().decodeBytes(bytes);
      bool success = false;
      for (var file in archive) {
        if (file.name == "image_0.png") {
          var filename = 'nai-generated-${generateRandomFileName()}.png';
          var imageBytes = file.content as Uint8List;
          await saveBlob(imageBytes, filename);
          log += 'Success: $filename${data['comment']}\n\n';
          img = Image.memory(imageBytes);
          success = true;
          break;
        }
      }
      if (!success) {
        log += 'Failed: Could not find image in HTTP response.\n\n';
      }
    } catch (e) {
      log += 'Failed: ${e.toString()}\n\n';
    } finally {
      isRequesting = false;
    }
    notifyListeners();

    if (isGenerating) {
      generateImage();
    }
  }

  void generatePrompt() {
    var data = getRequestData()['comment'];
    log += 'Generated prompt: $data\n\n';
    notifyListeners();
  }
}
