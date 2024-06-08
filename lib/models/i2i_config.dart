import 'dart:math';

import 'package:flutter/foundation.dart';

class I2IConfig with ChangeNotifier {
  // Basic settings
  String? _imgB64;
  double strength;
  double noise;

  // Prompt overrides
  bool overridePromptEnabled;
  String overridePrompt;

  // SMEA overrides
  bool overrideSmea;

  // Only-once settings
  bool once;

  Map<String, dynamic>? toJson() {
    if (_imgB64 == null) return null;
    Map<String, dynamic> parameters = {
      'image': _imgB64,
      'strength': strength,
      'noise': noise,
      'extra_noise_seed': Random().nextInt(1 << 32 - 1)
    };
    if (!overrideSmea) {
      parameters['sm'] = false;
      parameters['sm_dyn'] = false;
    }
    if (once) {
      _imgB64 = null;
      notifyListeners();
    }
    return {
      'action': 'img2img',
      'input': overridePromptEnabled ? overridePrompt : null,
      'parameters': parameters
    };
  }

  I2IConfig({
    String? imgB64,
    this.strength = 0.5,
    this.noise = 0,
    this.overridePromptEnabled = false,
    this.once = false,
    this.overridePrompt = '',
    this.overrideSmea = false,
  }) {
    _imgB64 = imgB64;
  }

  set imgB64(String? newValue) {
    _imgB64 = newValue;
    notifyListeners();
  }

  String? get imgB64 => _imgB64;
}
