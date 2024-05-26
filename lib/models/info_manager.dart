import 'dart:convert';
import 'dart:js_interop';
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

  final List<ImgInfo> _imgInfos = [];
  int _imgInfosCurrentIdx = 0;
  final int _imgInfosMaxLength = 200;
  List<ImgInfo> get imgInfos {
    return [
      ..._imgInfos.sublist(_imgInfosCurrentIdx),
      ..._imgInfos.sublist(0, _imgInfosCurrentIdx)
    ].reversed.toList();
  }

  String log = '';
  Image? img;
  bool isRequesting = false;
  bool isGenerating = false;

  bool showPromptParameters = true;

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

    var infoIdx = addNewInfo(ImgInfo(type: 'info', info: 'Requesting...'));

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
          // log += 'Success: $filename${data['comment']}\n\n';
          // img = Image.memory(imageBytes);
          _imgInfos[infoIdx] = ImgInfo(
              img: Image.memory(imageBytes),
              info: data['body']['input'] ?? '',
              type: 'img');
          success = true;
          break;
        }
      }
      if (!success) {
        _imgInfos[infoIdx] = ImgInfo(
            info: 'Error: cannot find image in HTTP response.', type: 'info');
      }
    } catch (e) {
      _imgInfos[infoIdx] =
          ImgInfo(info: 'Error: ${e.toString()}', type: 'info');
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
    addNewInfo(ImgInfo(img: null, info: content, type: 'info'));
  }

  int addNewInfo(ImgInfo newInfo) {
    if (imgInfos.length < _imgInfosMaxLength) {
      _imgInfos.add(newInfo);
      return _imgInfos.length - 1;
    } else {
      imgInfos[_imgInfosCurrentIdx] = newInfo;
      _imgInfosCurrentIdx = (_imgInfosCurrentIdx + 1) % _imgInfosMaxLength;
      return _imgInfosCurrentIdx - 1;
    }
  }
}
