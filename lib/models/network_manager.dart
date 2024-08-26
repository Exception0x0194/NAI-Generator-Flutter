import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class NetworkManager {
  String proxy = "";

  NetworkManager({this.proxy = ""});

  factory NetworkManager.fromJson(json) {
    return NetworkManager(proxy: json["proxy"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"proxy": proxy};
  }

  /// Sets proxy to input value.
  /// Input should follow pattern of `IP:Port`, like 127.0.0.1:12345.
  /// Throws exception if input is not valid proxy.
  void setProxy(String value) {
    if (!_isValidProxy(value)) {
      throw "Input proxy is not valid!";
    }
    proxy = value;
  }

  /// Get HTTP client from specified proxy settings.
  /// Returns `null` if app is running on Web.
  http.Client? createHttpClient() {
    // Avoid using proxy in web apps
    if (kIsWeb || proxy == '') return null;
    final ioClient = HttpClient();
    var clientProxy = 'PROXY $proxy';
    ioClient.findProxy = (uri) => clientProxy;
    // Ignore bad certification
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<http.Response> sendRequest(
    Uri apiUri,
    Map<String, String> headers,
    Map<String, dynamic> payload,
  ) async {
    final http.Response response;
    final client = createHttpClient();
    if (client == null) {
      response = await http.post(
        apiUri,
        headers: headers,
        body: json.encode(payload),
      );
    } else {
      response = await client.post(
        apiUri,
        headers: headers,
        body: json.encode(payload),
      );
    }
    return response;
  }

  bool _isValidProxy(String input) {
    if (input == '') return true;
    final ipPortRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}:\d{1,5}$');
    if (!ipPortRegex.hasMatch(input)) return false;
    return true;
  }
}
