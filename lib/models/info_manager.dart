import 'dart:convert';

import 'prompt_config.dart';
import 'param_config.dart';
import 'generation_info.dart';
import 'vibe_config.dart';
import 'i2i_config.dart';
import 'utils.dart';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

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

  // I2I / Enhance Config
  I2IConfig i2iConfig = I2IConfig();

  // Info of generated images
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

  // Cached payload
  Map<String, dynamic>? cachedPayload;

  // Generation display config
  bool showInfoForImg = true;
  double infoTileHeight = 1.0;

  // Persistent saved data
  late Box saveBox;

  Map<String, dynamic> toJson() {
    return {
      "api_key": apiKey,
      "preset_requests": presetRequests,
      "show_info_for_img": showInfoForImg,
      "info_tile_height": infoTileHeight,
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
      apiKey = jsonConfig['api_key'];
      presetRequests = jsonConfig['preset_requests'] ?? 0;
      showInfoForImg = jsonConfig['show_info_for_img'] ?? true;
      infoTileHeight = (jsonConfig['info_tile_height']?.toDouble() ?? 1.0);
      promptConfig = tryPromptConfig;
      paramConfig = tryParamConfig;
    } catch (e) {
      return false;
    }
    return true;
  }

  Map<String, String> get headers => {
        "authorization": "Bearer $apiKey",
        "referer": "https://novelai.net",
        "user-agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0"
      };

  Future<Map<String, dynamic>> getPayload() async {
    var pickedPrompts = promptConfig.pickPromptsFromConfig();
    var prompts = pickedPrompts['head']! + pickedPrompts['tail']!;

    var parameters = paramConfig.toJson();
    var action = 'generate';

    // Add vibe configs
    for (var config in vibeConfig) {
      parameters['reference_image_multiple'].add(config.imageB64);
      parameters['reference_information_extracted_multiple']
          .add(config.infoExtracted);
      parameters['reference_strength_multiple'].add(config.referenceStrength);
    }

    // Add I2I configs
    var i2iPayload = i2iConfig.toJson();
    if (i2iPayload != null) {
      action = i2iPayload['action'];
      prompts = i2iPayload['input'] ?? prompts;
      parameters.addAll(i2iPayload['parameters']);
    }

    return {
      "body": {
        "input": prompts,
        "model": "nai-diffusion-3",
        "action": action,
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
    if (isRequesting) return;
    var infoIdx = logRequestStart();

    // Prepare head & payload
    var url = Uri.parse('https://image.novelai.net/ai/generate-image');
    cachedPayload ??= await getPayload();

    notifyListeners();

    // Send request and handle response
    try {
      isRequesting = true;
      var bytes = await sendRequest(url, cachedPayload!['body']);
      handleResponse(bytes, cachedPayload!, infoIdx);
      cachedPayload = null;
    } catch (e) {
      setLog(infoIdx, 'Error occurred in HTTP response: ${e.toString()}');
    } finally {
      isRequesting = false;
      notifyListeners();
      if (isGenerating) generateImage();
    }
  }

  Future<Uint8List> sendRequest(Uri url, Map<String, dynamic> data) async {
    var response =
        await http.post(url, headers: headers, body: json.encode(data));
    return response.bodyBytes;
  }

  void handleResponse(Uint8List bytes, Map<String, dynamic> data, int infoIdx) {
    try {
      var archive = ZipDecoder().decodeBytes(bytes);
      if (!processArchive(archive, data, infoIdx)) {
        setLog(infoIdx, 'Error: Cannot find image_0.png in ZIP response.');
      }
    } catch (e) {
      setLog(infoIdx,
          'Error unpacking response: ${e.toString()};\nResponse data: ${bytes.length < 1000 ? utf8.decode(bytes) : 'TOO LONG!'}');
    }
  }

  bool processArchive(Archive archive, Map<String, dynamic> data, int infoIdx) {
    bool success = false;
    for (var file in archive) {
      if (file.name == "image_0.png") {
        saveImage(file, data, infoIdx);
        success = true;
        break;
      }
    }
    return success;
  }

  void saveImage(ArchiveFile file, Map<String, dynamic> data, int infoIdx) {
    var imageBytes = file.content as Uint8List;
    var filename =
        'nai-generated-${getTimestampDigits(_generationTimestamp)}-${_generationIdx.toString().padLeft(4, '0')}-${generateRandomFileName()}.png';
    saveBlob(imageBytes, filename);
    _generationInfos[infoIdx] = GenerationInfo(
        img: Image.memory(imageBytes, fit: BoxFit.fitHeight),
        info: {
          'filename': filename,
          'idx': infoIdx,
          'log': (data['comment'] as String),
          'prompt': data['body']['input'],
          'seed': data['body']['parameters']['seed'],
          'bytes': imageBytes,
          'height': data['body']['parameters']['height'],
          'width': data['body']['parameters']['width'],
        },
        type: 'img');
    _generationIdx++;
    decrementRequests();
  }

  void decrementRequests() {
    if (_remainingRequests > 0) {
      _remainingRequests--;
      if (_remainingRequests == 0) {
        addLog('Requests completed!');
        isGenerating = false;
      }
    }
  }

  void generatePrompt() async {
    var data = await getPayload();
    addNewInfo(GenerationInfo(
        info: {'log': data['comment'], 'prompt': data['body']['input']},
        type: 'info'));
    notifyListeners();
  }

  void addLog(String message) {
    addNewInfo(GenerationInfo(img: null, info: {'log': message}, type: 'info'));
  }

  int logRequestStart() {
    String log = _remainingRequests == 0
        ? 'Looping - '
        : '${_remainingRequests.toString()} request${_remainingRequests > 1 ? 's' : ''} remaining - ';
    return addNewInfo(
        GenerationInfo(type: 'info', info: {'log': '${log}Requesting...'}));
  }

  void setLog(int infoIdx, String message) {
    _generationInfos[infoIdx].info['log'] = message;
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

  void saveConfig() {
    saveBox.put('savedConfig', json.encode(toJson()));
  }
}
