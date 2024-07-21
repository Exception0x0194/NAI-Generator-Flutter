import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'generation_info.dart';
import 'utils.dart';

class NetworkManager {
  // API token
  String apiToken;
  // Proxy
  String proxy;
  // Debug API
  String debugApiPath;
  bool debugApiEnabled;

  NetworkManager(
      {this.apiToken = 'pst-abcd',
      this.proxy = '',
      this.debugApiPath = 'http://localhost:5000/ai/generate-image',
      this.debugApiEnabled = false});

  Map<String, dynamic> toJson() {
    return {
      'api_token': apiToken,
      'proxy': proxy,
      'debug_api_path': debugApiPath,
      'debug_api_enabled': debugApiEnabled
    };
  }

  Map<String, String> get header => {
        "authorization": "Bearer $apiToken",
        "referer": "https://novelai.net",
        "user-agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0"
      };

  NetworkManager fromJson(Map<String, dynamic> json) {
    return NetworkManager(
        apiToken: json['api_token'],
        proxy: json['proxy'],
        debugApiPath: json['debug_api_path'],
        debugApiEnabled: json['debug_api_enabled']);
  }

  http.Client? createHttpClient() {
    // Avoid using proxy for web
    if (kIsWeb || proxy == '') return null;
    final ioClient = HttpClient();
    var clientProxy = 'PROXY $proxy';
    ioClient.findProxy = (uri) => clientProxy;
    // Ignore bad certification
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<Uint8List> sendRequest(Uri url, Map<String, dynamic> data) async {
    final client = createHttpClient();
    http.Response response;
    if (client != null) {
      response =
          await client.post(url, headers: header, body: json.encode(data));
    } else {
      response = await http.post(url, headers: header, body: json.encode(data));
    }
    return response.bodyBytes;
  }
}

class BatchManager with ChangeNotifier {
  // Batch countdown
  int batchCount;
  int batchIntervalSec;
  int _batchCountdown = 0;
  Timer? _batchWaitingTimer;
  // Schdule
  int scheduleCount;
  int _scheduleCountdown = 0;

  BatchManager(
      {this.batchCount = 10,
      this.batchIntervalSec = 10,
      this.scheduleCount = 0});

  Map<String, dynamic> toJson() {
    return {'batch_count': batchCount, 'batch_interval': batchIntervalSec};
  }

  BatchManager fromJson(Map<String, dynamic> json) {
    return BatchManager(
        batchCount: json['batch_count'],
        batchIntervalSec: json['batch_interval']);
  }

  bool get isWaiting {
    return _batchWaitingTimer != null;
  }

  bool get isLooping {
    return scheduleCount == 0;
  }

  int get remainingRequests {
    return _scheduleCountdown;
  }

  void startNewBatch() {
    _batchCountdown = batchCount;
    _scheduleCountdown = scheduleCount;
  }

  void descCountdown() {
    _batchCountdown--;
    if (_batchCountdown <= 0 && _batchWaitingTimer != null) {
      // If batch is finished, start cooldown timer
      if (_batchWaitingTimer == null) {
        _batchWaitingTimer = Timer(Duration(seconds: batchIntervalSec), () {
          // Continue generation after cooldown
          _batchCountdown = batchCount;
          _batchWaitingTimer = null;
          notifyListeners();
        });
        notifyListeners();
      }
    }
  }
}

class ResponseHandler {
  ArchiveFile? handleResponse(Uint8List bytes) {
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      if (file.name == "image_0.png") {
        return file;
      }
    }
    return null;
  }
}

class GenerationOutputManager with ChangeNotifier {
  // Info of generated images
  final List<GenerationInfo> _generationInfos = [];
  int _generationInfoCurrentIdx = 0;
  int _generationCount = 0;
  final int _generationInfosMaxLength = 200;
  List<GenerationInfo> get infoList {
    return [
      ..._generationInfos.sublist(_generationInfoCurrentIdx),
      ..._generationInfos.sublist(0, _generationInfoCurrentIdx)
    ].reversed.toList();
  }

  void setLog(int infoIdx, String message) {
    _generationInfos[infoIdx].info['log'] = message;
    notifyListeners();
  }

  int addNewInfo(GenerationInfo newInfo) {
    newInfo.info['idx'] = _generationCount;
    _generationCount++;
    int addedIndex;
    if (_generationInfos.length < _generationInfosMaxLength) {
      _generationInfos.add(newInfo);
      addedIndex = _generationInfos.length - 1;
    } else {
      _generationInfos[_generationInfoCurrentIdx] = newInfo;
      addedIndex = _generationInfoCurrentIdx;
      _generationInfoCurrentIdx =
          (_generationInfoCurrentIdx + 1) % _generationInfosMaxLength;
    }
    notifyListeners();
    return addedIndex;
  }
}
