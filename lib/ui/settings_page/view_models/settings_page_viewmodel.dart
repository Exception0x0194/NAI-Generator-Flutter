import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/core/constants/settings.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/data/models/settings.dart';
import 'package:nai_casrand/data/services/config_service.dart';
import 'package:nai_casrand/data/services/file_service.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';

class SettingsPageViewmodel extends ChangeNotifier {
  PayloadConfig get payloadConfig => GetIt.I();
  ConfigService get configService => GetIt.I();

  SettingsPageViewmodel();

  Settings get settings {
    return payloadConfig.settings;
  }

  void setApiKey(String value) {
    payloadConfig.settings.apiKey = value;
    notifyListeners();
  }

  void setBatchCount(String value) {
    final parseResult = int.tryParse(value);
    if (parseResult == null) return;
    payloadConfig.settings.batchCount = parseResult;
    notifyListeners();
  }

  void setBatchIntervalSet(String value) {
    final parseResult = int.tryParse(value);
    if (parseResult == null) return;
    payloadConfig.settings.batchIntervalSec = parseResult;
    notifyListeners();
  }

  void setNumberOfRequests(String value) {
    final parseResult = int.tryParse(value);
    if (parseResult == null) return;
    payloadConfig.settings.numberOfRequests = parseResult;
    notifyListeners();
  }

  void setEraseMetadataEnabled(bool? value) {
    if (value == null) return;
    payloadConfig.settings.metadataEraseEnabled = value;
    notifyListeners();
  }

  void setCustomMetadataEnabled(bool? value) {
    if (value == null) return;
    payloadConfig.settings.customMetadataEnabled = value;
    notifyListeners();
  }

  void setCustomMetadataContent(String value) {
    payloadConfig.settings.customMetadataContent = value;
    notifyListeners();
  }

  void pickOutputFolderPath() async {
    final pickResult = await FilePicker.platform.getDirectoryPath();
    if (pickResult == null) return;
    payloadConfig.settings.outputFolderPath = pickResult;
    notifyListeners();
  }

  void setProxy(String value) {
    bool isValidProxy(String input) {
      if (input == '') return true;
      final ipPortRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}:\d{1,5}$');
      if (!ipPortRegex.hasMatch(value)) return false;
      return true;
    }

    if (!isValidProxy(value)) return;
    payloadConfig.settings.proxy = value;
    notifyListeners();
  }

  void loadJsonConfig(BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);
    if (result == null) return;
    try {
      var fileContent = utf8.decode(result.files.single.bytes!);
      Map<String, dynamic> jsonData = json.decode(fileContent);
      payloadConfig.loadJson(jsonData);
      if (!context.mounted) return;
      showInfoBar(context, '${tr('info_import_file')}${tr('succeed')}');
    } catch (error) {
      if (!context.mounted) return;
      showErrorBar(context,
          '${tr('info_import_file')}${tr('failed')}: ${error.toString()}');
    }
  }

  void setFileNamePrefixKey(String value) {
    payloadConfig.settings.fileNamePrefixKey = value;
    notifyListeners();
  }

  void saveJsonConfig() {
    final configJson = payloadConfig.toJson();
    final filename =
        'nai-generator-config-${FileService().generateRandomString()}.json';
    FileService().saveStringToFile(
      json.encode(configJson),
      filename,
    );
  }

  void setThemeMode(String value, BuildContext context) {
    payloadConfig.settings.themeMode = value;
    AdaptiveTheme.of(context).setThemeMode(stringToThemeMode[value]!);
    notifyListeners();
  }

  void notify() => notifyListeners();

  void saveCurrentConfig() {
    configService.saveConfig(payloadConfig.toJson());
  }
}
