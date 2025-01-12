import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class ConfigService {
  late PackageInfo packageInfo;
  late Box saveBox;

  Future<Map<String, dynamic>> loadDefaultConfig() async {
    Map<String, dynamic> jsonData =
        json.decode(await rootBundle.loadString('assets/json/example.json'));

    return jsonData;
  }

  Future<Map<String, dynamic>> loadSavedConfig() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    saveBox = await Hive.openBox('savedBox');
    String? jsonData = saveBox.get('savedConfig');
    if (jsonData == null) return loadDefaultConfig();
    return json.decode(jsonData);
  }

  Future<void> saveConfig(String encodedConfig) async {
    saveBox.put('savedConfig', encodedConfig);
  }
}
