import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/data/services/config_service.dart';
import 'package:nai_casrand/data/services/file_service.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:uuid/uuid.dart';

class ConfigSelectionPageViewmodel extends ChangeNotifier {
  ConfigService get configService => GetIt.I();
  PayloadConfig get payloadConfig => GetIt.I();
  Map<String, SavedConfigInfo> get configIndexes => configService.configIndex;

  ConfigSelectionPageViewmodel();

  void deleteConfig(BuildContext context, String uuid) {
    configService.deleteConfigByUuid(uuid);
    notifyListeners();
  }

  void saveCopyOfCurrentConfig(BuildContext context) {
    final jsonData = payloadConfig.toJson();
    final currentUuid = configService.currentUuid;
    final currentName = configIndexes[currentUuid]!.title;
    final newUuid = const Uuid().v4();
    configService.saveConfigByUuid(newUuid, jsonData);
    configService.renameConfigByUuid(
        newUuid, '${tr('copied_config')}${tr('colon')}$currentName');
    notifyListeners();
  }

  void importConfigFromFile(BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);
    if (result == null) return;
    try {
      final fileContent = utf8.decode(result.files.single.bytes!);
      final fileName = result.files.single.name;
      Map<String, dynamic> jsonData = json.decode(fileContent);
      final uuid = const Uuid().v4();
      configService.saveConfigByUuid(uuid, jsonData);
      configService.renameConfigByUuid(
          uuid, '${tr('imported_config')}${tr('colon')}$fileName');
      notifyListeners();
    } catch (error) {
      if (!context.mounted) return;
      showErrorBar(context,
          '${tr('info_import_file')}${tr('failed')}: ${error.toString()}');
    }
  }

  void loadSavedConfig(BuildContext context, String uuid) {
    final jsonData = configService.loadConfigByUuid(uuid);
    if (jsonData == null) {
      deleteConfig(context, uuid);
      return;
    }
    payloadConfig.loadJson(jsonData);
    configService.currentUuid = uuid;
    notifyListeners();
    showInfoBar(context, '${tr('info_load_saved_config')}${tr('succeed')}');
  }

  void saveConfigAsFile(BuildContext context, String uuid) {
    final configJson = configService.loadConfigByUuid(uuid);
    final filename =
        'nai-generator-config-${FileService().generateRandomString()}.json';
    FileService().saveStringToFile(
      json.encode(configJson),
      filename,
    );
  }

  void setConfigName(String uuid, String title) {
    configService.renameConfigByUuid(uuid, title);
    notifyListeners();
  }
}
