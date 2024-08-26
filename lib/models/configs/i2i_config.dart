import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image_size_getter/image_size_getter.dart';

class I2IConfig with ChangeNotifier {
  // Basic settings
  String? imageB64;
  int width = 0;
  int height = 0;

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
    if (imageB64 == null) return null;
    Map<String, dynamic> parameters = {
      'image': imageB64,
      'strength': strength,
      'noise': noise,
      'extra_noise_seed': Random().nextInt(1 << 32 - 1)
    };
    if (!overrideSmea) {
      parameters['sm'] = false;
      parameters['sm_dyn'] = false;
    }
    if (once) {
      imageB64 = null;
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
    imageB64 = imgB64;
  }

  void setImage(Uint8List bytes) {
    final size = ImageSizeGetter.getSize(MemoryInput(bytes));
    width = size.width;
    height = size.height;
    imageB64 = base64Encode(bytes);
    notifyListeners();
  }
}
