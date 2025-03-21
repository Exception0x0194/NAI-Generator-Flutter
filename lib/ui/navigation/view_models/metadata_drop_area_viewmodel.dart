import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';

class MetadataDropAreaViewmodel extends ChangeNotifier {
  PayloadConfig get payloadConfig => GetIt.I();
  ParamConfig get config => payloadConfig.paramConfig;

  void loadAllMetadata(
    BuildContext context,
    Map<String, dynamic> commentData,
    String? prompt,
    String? model,
  ) {
    int loadedCount = config.loadJson(commentData);
    if (prompt != null) {
      payloadConfig.overridePrompt = prompt;
      payloadConfig.useOverridePrompt = true;
      loadedCount++;
    }
    if (model != null) {
      payloadConfig.paramConfig.model = model;
      loadedCount++;
    }
    notifyListeners();
    showInfoBar(
        context,
        tr(
          'loaded_parameters_count',
          namedArgs: {'num': loadedCount.toString()},
        ));
  }

  void loadSingleImageMetadata(
      BuildContext context, Map<String, dynamic> commentData, String key) {
    final loadedCount = config.loadJson(commentData);
    if (loadedCount == 0) return;
    notifyListeners();
    showInfoBar(
        context,
        tr(
          'pasted_parameter',
          namedArgs: {'parameter_name': key},
        ));
  }

  void setOverridePrompt(BuildContext context, String? prompt) {
    if (prompt == null) return;
    payloadConfig.overridePrompt = prompt;
    payloadConfig.useOverridePrompt = true;
    notifyListeners();
    showInfoBar(
        context,
        tr(
          'pasted_parameter',
          namedArgs: {'parameter_name': tr('prompt')},
        ));
  }

  void setModel(String model) {
    config.model = model;
    notifyListeners();
  }
}
