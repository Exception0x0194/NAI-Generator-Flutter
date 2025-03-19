import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/data/models/generation_size.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';

class ParametersConfigViewmodel extends ChangeNotifier {
  PayloadConfig get payloadConfig => GetIt.I();
  ParamConfig get config => payloadConfig.paramConfig;

  ParametersConfigViewmodel();

  setSteps(double value) {
    config.steps = value.toInt();
    notifyListeners();
  }

  setScale(double value) {
    config.scale = value;
    notifyListeners();
  }

  setCfgRescale(double value) {
    config.cfgRescale = value;
    notifyListeners();
  }

  setSampler(String value) {
    config.sampler = value;
    notifyListeners();
  }

  setNoiseScheduler(String value) {
    config.noiseSchedule = value;
    notifyListeners();
  }

  setSm(bool value) {
    config.sm = value;
    notifyListeners();
  }

  setSmDyn(bool value) {
    config.smDyn = value;
    notifyListeners();
  }

  setVarietyPlus(bool value) {
    config.varietyPlus = value;
    notifyListeners();
  }

  setNegativePrompt(String value) {
    config.negativePrompt = value;
    notifyListeners();
  }

  setRandomSeedEnabled(bool value) {
    config.randomSeed = value;
    notifyListeners();
  }

  setSeed(String value) {
    final parseResult = int.tryParse(value);
    if (parseResult == null) return;
    config.seed = parseResult;
    notifyListeners();
  }

  void removeSize(GenerationSize elem) {
    if (config.sizes.length == 1) return;
    final list = config.sizes.toList();
    list.remove(elem);
    config.sizes = list;
    notifyListeners();
  }

  void addSize(GenerationSize elem) {
    if (config.sizes.contains(elem)) return;
    final list = config.sizes.toList();
    list.add(elem);
    config.sizes = list;
    notifyListeners();
  }

  void addManualSize(String width, String height) {
    var parsedWigth = int.tryParse(width);
    var parsedHeight = int.tryParse(height);
    if (parsedWigth == null || parsedHeight == null) return;
    parsedWigth = (parsedWigth / 64).ceil() * 64;
    parsedHeight = (parsedHeight / 64).ceil() * 64;
    final size = GenerationSize(width: parsedWigth, height: parsedHeight);
    if (config.sizes.contains(size)) return;
    final list = config.sizes.toList();
    list.add(size);
    config.sizes = list;
    notifyListeners();
  }

  void setModel(String value) {
    config.model = value;
    notifyListeners();
  }

  bool get isV4 => config.model.contains('-4-');

  void setAutoPosition(bool? value) {
    if (value == null) return;
    config.autoPosition = value;
    notifyListeners();
  }

  void setLegacyUc(bool? value) {
    if (value == null) return;
    config.legacyUc = value;
    notifyListeners();
  }

  void loadImageMetadata(
      BuildContext context, Map<String, dynamic> commentData) {
    final loadedCount = config.loadJson(commentData);
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
}
