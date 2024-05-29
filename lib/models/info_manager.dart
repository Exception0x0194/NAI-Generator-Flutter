import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'prompt_config.dart';
import 'param_config.dart';
import 'generation_info.dart';
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

  final List<GenerationInfo> _generationInfos = [];
  int _generationInfoCurrentIdx = 0;
  int _generationCount = 0;
  final int _generationInfosMaxLength = 200;
  List<GenerationInfo> get generationInfos {
    return [
      ..._generationInfos.sublist(_generationInfoCurrentIdx),
      ..._generationInfos.sublist(0, _generationInfoCurrentIdx)
    ].reversed.toList();
  }

  bool isRequesting = false;
  int remainingRequests = 0;
  bool isGenerating = false;

  bool showCompactPromptView = false;
  bool showInfoForImg = true;

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

    String log = remainingRequests == 0
        ? 'Looping - '
        : '${remainingRequests.toString()} request${remainingRequests > 1 ? 's' : ''} remaining - ';
    var infoIdx = addNewInfo(
        GenerationInfo(type: 'info', info: {'log': '${log}Requesting...'}));

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
          var img = Image.memory(
            imageBytes,
            fit: BoxFit.fitHeight,
          );

          _generationInfos[infoIdx] = GenerationInfo(
              img: img,
              info: {
                'filename': filename,
                'idx': infoIdx,
                'log': (data['comment'] as String).substring(1),
                'prompt': data['body']['input'],
                'seed': data['body']['parameters']['seed'],
                'height': data['body']['parameters']['height'],
                'width': data['body']['parameters']['width'],
              },
              type: 'img');
          success = true;
          if (remainingRequests > 0) {
            remainingRequests--;
            if (remainingRequests == 0) {
              addLog('Requests completed!');
              isGenerating = false;
            }
          }
          break;
        }
      }
      if (!success) {
        _generationInfos[infoIdx].info['log'] =
            'Error: Cannot find image in HTTP response';
      }
    } catch (e) {
      _generationInfos[infoIdx].info['log'] = 'Error: ${e.toString()}';
    } finally {
      isRequesting = false;
    }
    notifyListeners();

    if (isGenerating) {
      generateImage();
    }
  }

  void generatePrompt() {
    var data = (getRequestData()['comment'] as String).substring(1);
    addLog(data);
    notifyListeners();
  }

  void addLog(String content) {
    addNewInfo(GenerationInfo(img: null, info: {'log': content}, type: 'info'));
  }

  int addNewInfo(GenerationInfo newInfo) {
    newInfo.info['idx'] = _generationCount;
    _generationCount++;
    if (_generationInfos.length < _generationInfosMaxLength) {
      _generationInfos.add(newInfo);
      return _generationInfos.length - 1;
    } else {
      _generationInfos[_generationInfoCurrentIdx] = newInfo;
      int addedIndex = _generationInfoCurrentIdx;
      _generationInfoCurrentIdx =
          (_generationInfoCurrentIdx + 1) % _generationInfosMaxLength;
      return addedIndex;
    }
  }
}
