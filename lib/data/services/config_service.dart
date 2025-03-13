import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class ConfigService {
  late PackageInfo packageInfo;
  late Box saveBox;

  late Map<String, dynamic> configIndex;

  Future<Map<String, dynamic>> loadDefaultConfig() async {
    Map<String, dynamic> jsonData =
        json.decode(await rootBundle.loadString('assets/json/example.json'));

    return jsonData;
  }

  Future<Map<String, dynamic>> loadSavedConfig() async {
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    }
    saveBox = await Hive.openBox('savedBox');
    configIndex = loadConfigIndex();
    String? jsonData = saveBox.get('savedConfig');
    if (jsonData == null) return loadDefaultConfig();
    return json.decode(jsonData);
  }

  Future<void> saveConfig(String encodedConfig) async {
    saveBox.put('savedConfig', encodedConfig);
  }

  /// Returns `{'uuid1': 'title1', 'uuid2': 'title2', ...}`
  Map<String, dynamic> loadConfigIndex() {
    final jsonData = saveBox.get('configIndex');
    if (jsonData == null) {
      return {};
    }
    return json.decode(jsonData);
  }

  void saveConfigIndex() {
    saveBox.put('configIndex', json.encode(configIndex));
  }

  Map<String, dynamic>? loadConfigByUuid(String uuid) {
    final configJsonString = saveBox.get('savedConfig-$uuid');
    if (configJsonString == null) {
      return null;
    }
    return json.decode(configJsonString);
  }

  void renameConfigByUuid(String uuid, String title) {
    if (!configIndex.containsKey(uuid)) return;
    configIndex[uuid] = title;
    saveConfigIndex();
  }

  void saveConfigByUuid(
    String uuid,
    String title,
    Map<String, dynamic> jsonData,
  ) {
    saveBox.put('savedConfig-$uuid', json.encode(jsonData));
    if (!configIndex.containsKey(uuid)) {
      configIndex[uuid] = title;
      saveConfigIndex();
    }
  }

  void deleteConfigByUuid(String uuid) {
    saveBox.delete('savedConfig-$uuid');
    configIndex.remove(uuid);
  }
}
