import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ConfigService {
  late PackageInfo packageInfo;

  Future<Map<String, dynamic>> loadDefaultPayloadConfig() async {
    Map<String, dynamic> jsonData =
        json.decode(await rootBundle.loadString('assets/json/example.json'));

    return jsonData;
  }
}
