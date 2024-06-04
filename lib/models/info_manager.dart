import 'dart:convert';

import 'prompt_config.dart';
import 'param_config.dart';
import 'generation_info.dart';
import 'vibe_config.dart';
import 'utils.dart';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfoManager with ChangeNotifier {
  static final InfoManager _instance = InfoManager._internal();
  factory InfoManager() {
    return _instance;
  }
  InfoManager._internal();

  // Generation Config
  String apiKey = 'pst-abcd';
  late PromptConfig promptConfig = PromptConfig();
  ParamConfig paramConfig = ParamConfig();

  // Vibe Config
  List<VibeConfig> vibeConfig = [];

  // Generated info
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

  // Request status
  bool isRequesting = false;
  int presetRequests = 0;
  int _remainingRequests = 0;
  bool isGenerating = false;

  // Output indexing
  DateTime _generationTimestamp = DateTime.now();
  int _generationIdx = 0;

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
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0"
      };

  Map<String, dynamic> getPayload() {
    var pickedPrompts = promptConfig.pickPromptsFromConfig();
    var prompts = pickedPrompts['head']! + pickedPrompts['tail']!;

    var parameters = paramConfig.toJson();
    // Add vibe configs
    for (var config in vibeConfig) {
      parameters['reference_image_multiple'].add(config.imageB64);
      parameters['reference_information_extracted_multiple']
          .add(config.infoExtracted);
      parameters['reference_strength_multiple'].add(config.referenceStrength);
    }

    return {
      "body": {
        "input": prompts,
        "model": "nai-diffusion-3",
        "action": "generate",
        "parameters": parameters,
      },
      "comment": pickedPrompts['comment']
    };
  }

  void startGeneration() {
    _generationTimestamp = DateTime.now();
    _generationIdx = 0;
    _remainingRequests = presetRequests;
    generateImage();
  }

  Future<void> generateImage() async {
    // Add new info entry
    if (isRequesting) {
      return;
    }
    String log = _remainingRequests == 0
        ? 'Looping - '
        : '${_remainingRequests.toString()} request${_remainingRequests > 1 ? 's' : ''} remaining - ';
    var infoIdx = addNewInfo(
        GenerationInfo(type: 'info', info: {'log': '${log}Requesting...'}));
    notifyListeners();

    // Prepare head & payload
    var url = Uri.parse('https://image.novelai.net/ai/generate-image');
    var data = getPayload();

    // Send request
    var bytes = Uint8List(0);
    try {
      isRequesting = true;
      var response = await http.post(url,
          headers: headers, body: json.encode(data['body']));
      bytes = response.bodyBytes;
    } catch (e) {
      _generationInfos[infoIdx].info['log'] =
          'Error orrurred in HTTP request: ${e.toString()}';
      notifyListeners();
      if (isGenerating) generateImage();
      return;
    } finally {
      isRequesting = false;
    }

    // Unpack & read response
    try {
      var archive = ZipDecoder().decodeBytes(bytes);
      bool success = false;
      for (var file in archive) {
        // Find "image_0.png"
        if (file.name != "image_0.png") continue;
        var filename =
            'nai-generated-${getTimestampDigits(_generationTimestamp)}-${_generationIdx.toString().padLeft(4, '0')}-${generateRandomFileName()}.png';
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
              'log': (data['comment'] as String),
              'prompt': data['body']['input'],
              'seed': data['body']['parameters']['seed'],
              'height': data['body']['parameters']['height'],
              'width': data['body']['parameters']['width'],
            },
            type: 'img');
        success = true;
        _generationIdx++;
        if (_remainingRequests > 0) {
          _remainingRequests--;
          if (_remainingRequests == 0) {
            addLog('Requests completed!');
            isGenerating = false;
          }
        }
        break;
      }
      if (!success) {
        _generationInfos[infoIdx].info['log'] =
            'Error: Cannot find image_0.png in ZIP response';
      }
    } catch (e) {
      _generationInfos[infoIdx].info['log'] =
          'Error unpacking response: ${e.toString()};\nResponse data: ${utf8.decode(bytes)}';
    }

    // Start new generation
    notifyListeners();
    if (isGenerating) generateImage();
  }

  void generatePrompt() {
    var data = getPayload();
    addNewInfo(GenerationInfo(
        info: {'log': data['comment'], 'prompt': data['body']['input']},
        type: 'info'));
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
