import 'package:flutter/material.dart';
import 'package:nai_casrand/data/models/param_config.dart';

class ParametersTabViewmodel extends ChangeNotifier {
  ParamConfig config;

  ParametersTabViewmodel({required this.config});

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
}
