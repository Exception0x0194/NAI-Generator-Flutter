import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'network_manager.dart';

class BatchManager extends ChangeNotifier {
  // Batch settings
  int batchCount = 10;
  int batchIntervalSec = 10;
  // Number of requests
  int numberOfRequests = 0;

  bool started = false;
  int remainingRequests = 0;
  int batchCountdown = 0;
  Timer? batchWaitingTimer;

  Map<String, dynamic>? _cachedPayload;

  NetworkManager networkManager = NetworkManager();

  BatchManager({
    this.batchCount = 10,
    this.batchIntervalSec = 10,
    this.numberOfRequests = 0,
    NetworkManager? networkManager,
  }) {
    if (networkManager != null) {
      this.networkManager = networkManager;
    } else {
      this.networkManager = NetworkManager();
    }
  }

  factory BatchManager.fromJson(Map<String, dynamic> json) {
    return BatchManager(
        batchCount: json["batch_count"] ?? 10,
        batchIntervalSec: json["batch_interval"] ?? 10,
        numberOfRequests: json["preset_requests"] ?? 0,
        networkManager:
            NetworkManager.fromJson(json["network_manager_config"]));
  }

  Map<String, dynamic> toJson() {
    return {
      "batch_count": batchCount,
      "batch_interval": batchIntervalSec,
      "preset_requests": numberOfRequests,
      "network_manager_config": networkManager.toJson(),
    };
  }

  void startGeneration(
    Uri apiUri,
    Map<String, String> headers,
    Map<String, dynamic> Function() payloadBuilder,
    bool Function(http.Response) responseHandler,
  ) {
    // Won't start if still in pause between batches
    if (started || batchWaitingTimer != null) return;
    started = true;
    _cachedPayload = null;
    remainingRequests = numberOfRequests;
    _startNewBatch(apiUri, headers, payloadBuilder, responseHandler);
  }

  void stopGeneration() {
    if (!started) return;
    started = false;
    notifyListeners();
  }

  void _startNewBatch(
    Uri apiUri,
    Map<String, String> headers,
    Map<String, dynamic> Function() payloadBuilder,
    bool Function(http.Response) responseHandler,
  ) {
    if (!started) return;
    batchCountdown = batchCount;
    batchWaitingTimer = null;
    _sendNextRequest(apiUri, headers, payloadBuilder, responseHandler);
  }

  void _sendNextRequest(
    Uri apiUri,
    Map<String, String> headers,
    Map<String, dynamic> Function() payloadBuilder,
    bool Function(http.Response) responseHandler,
  ) async {
    _cachedPayload ??= payloadBuilder();
    notifyListeners();
    final response =
        await networkManager.sendRequest(apiUri, headers, _cachedPayload!);
    if (responseHandler(response)) {
      _cachedPayload = null;
      remainingRequests--;
      batchCountdown--;
    }
    // Stop generation if number of generation if reached
    if (remainingRequests <= 0) {
      stopGeneration();
      return;
    }
    // Pause if batch count is reached
    if (batchCountdown <= 0) {
      batchWaitingTimer = Timer(Duration(seconds: batchIntervalSec), () {
        // Start new batch after the pause
        _startNewBatch(apiUri, headers, payloadBuilder, responseHandler);
        notifyListeners();
      });
      notifyListeners();
      return;
    }
    if (started) {
      _sendNextRequest(apiUri, headers, payloadBuilder, responseHandler);
    }
  }
}
