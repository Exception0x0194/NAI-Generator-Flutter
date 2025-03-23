import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nai_casrand/data/models/prompt_config.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';

class SavedConfigListViewmodel extends ChangeNotifier {
  List<PromptConfig> configList;

  SavedConfigListViewmodel({required this.configList});

  void addConfig(BuildContext context) {
    configList.add(PromptConfig(strs: [], prompts: []));
    notifyListeners();
  }

  Future importConfigFromClipboard(BuildContext context) async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      try {
        final Map<String, dynamic> jsonConfig = json.decode(data.text!);
        final newConfig = PromptConfig.fromJson(jsonConfig);
        configList.add(newConfig);
        if (!context.mounted) return;
        showInfoBar(context,
            '${context.tr('info_import_from_clipboard')}${context.tr('succeed')}');
      } catch (e) {
        if (!context.mounted) return;
        showErrorBar(context,
            '${context.tr('info_import_from_clipboard')}${context.tr('failed')}');
      }
    }
    notifyListeners();
  }

  void removeConfig(PromptConfig elem) {
    configList.remove(elem);
    notifyListeners();
  }
}
