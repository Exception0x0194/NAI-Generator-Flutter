import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nai_casrand/data/models/prompt_config.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';

class PromptConfigViewModel extends ChangeNotifier {
  PromptConfig config;
  bool isRoot;
  bool initiallyExpanded;

  PromptConfigViewModel({
    required this.config,
    this.isRoot = true,
    this.initiallyExpanded = true,
  });

  bool get isEnabled => isRoot ? true : config.enabled;

  void setSelectionMethod(String value) {
    config.selectionMethod = value;
    notifyListeners();
  }

  void setProb(double value) {
    config.prob = value;
    notifyListeners();
  }

  void setNum(int value) {
    config.num = value;
    notifyListeners();
  }

  void setShuffled(bool value) {
    config.shuffled = value;
    notifyListeners();
  }

  void setType(String value) {
    config.type = value;
    notifyListeners();
  }

  void setComment(String value) {
    config.comment = value;
    notifyListeners();
  }

  void setEnabled(bool value) {
    config.enabled = value;
    notifyListeners();
  }

  void setRandomBrackets(int lower, int upper) {
    config.randomBracketsLower = lower;
    config.randomBracketsUpper = upper;
    notifyListeners();
  }

  void setStrs(String value) {
    config.strs = value.split('\n').where((str) => str.isNotEmpty).toList();
    notifyListeners();
  }

  String getConfigDescrption(BuildContext context) {
    String ret = '';
    // Selection method-related parameters
    switch (config.selectionMethod) {
      case 'all':
        ret += '${context.tr('selection_method_all')} / ';
        break;
      case 'single':
        ret += '${context.tr('selection_method_single')} / ';
        break;
      case 'single_sequential':
        ret += context.tr('selection_method_single_sequential');
        if (config.num > 1) {
          ret += context.tr('single_sequential_repeats',
              namedArgs: {'num': config.num.toString()});
        }
        ret += ' / ';
        break;
      case 'multiple_num':
        ret +=
            '${context.tr('selection_method_multiple_num')}: ${config.num} / ';
        break;
      case 'multiple_prob':
        ret +=
            '${context.tr('selection_method_multiple_prob')}: ${config.prob} / ';
    }
    if (config.selectionMethod == 'all' ||
        config.selectionMethod == 'multiple_prob') {
      ret +=
          '${config.shuffled ? context.tr('is_shuffled') : context.tr('is_ordered')} / ';
    }
    // Config type
    if (config.type == 'str') {
      ret += context.tr('cascaded_config_type_str');
    } else {
      ret += context.tr('cascaded_config_type_config');
    }
    // Random brackets
    final lower = config.randomBracketsLower;
    final upper = config.randomBracketsUpper;
    if (lower != 0 || upper != 0) {
      ret += ' / ${lower.toString()} ~ ${upper.toString()}';
    }
    return ret;
  }

  List<PromptConfigViewModel> get subConfigs => config.prompts
      .map((promptConfig) => PromptConfigViewModel(
            config: promptConfig,
            isRoot: false,
            initiallyExpanded: false,
          ))
      .toList();

  Future importConfigFromClipboard(BuildContext context) async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      try {
        final Map<String, dynamic> jsonConfig = json.decode(data.text!);
        final newConfig = PromptConfig.fromJson(jsonConfig);
        if (config.prompts.isEmpty) {
          config.prompts = [newConfig];
        } else {
          config.prompts.add(newConfig); // 如果位置无效，添加到末尾
        }
        if (!context.mounted) return;
        showErrorBar(context,
            '${context.tr('info_import_from_clipboard')}${context.tr('succeed')}');
      } catch (e) {
        if (!context.mounted) return;
        showErrorBar(context,
            '${context.tr('info_import_from_clipboard')}${context.tr('failed')}');
      }
    }
    notifyListeners();
  }

  void copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: json.encode(config.toJson())));
    if (!context.mounted) return;
    showInfoBar(context,
        '${context.tr('info_export_to_clipboard')}${context.tr('succeed')}');
  }

  void addNewConfig() {
    config.prompts.add(PromptConfig(strs: [], prompts: []));
    notifyListeners();
  }

  void removeConfigAt(int index) {
    config.prompts.removeAt(index);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var item = config.prompts.removeAt(oldIndex);
    config.prompts.insert(newIndex, item);
    notifyListeners();
  }
}
