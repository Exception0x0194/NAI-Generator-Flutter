import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image_size_getter/image_size_getter.dart';

class I2IConfigResult {
  String imageB64;
  double strength;
  double noise;
  int extraNoiseSeed;
  String? overridePrompts;

  I2IConfigResult({
    required this.imageB64,
    required this.strength,
    required this.noise,
    required this.extraNoiseSeed,
    required this.overridePrompts,
  });
}

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

  I2IConfigResult getConfigResult() {
    if (imageB64 == null) {
      throw Exception('I2I input image is null!');
    }
    return I2IConfigResult(
      imageB64: imageB64!,
      strength: strength,
      noise: noise,
      extraNoiseSeed: Random().nextInt(1 << 32 - 1),
      overridePrompts: overridePrompt,
    );
  }

  I2IConfig({
    this.imageB64,
    this.strength = 0.5,
    this.noise = 0,
    this.overridePromptEnabled = false,
    this.overridePrompt = '',
  });

  void setImage(Uint8List bytes) {
    final size = ImageSizeGetter.getSize(MemoryInput(bytes));
    width = size.width;
    height = size.height;
    imageB64 = base64Encode(bytes);
    notifyListeners();
  }
}
