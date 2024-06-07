import 'dart:convert';
import 'dart:typed_data';

class I2IConfig {
  // Basic settings
  String? _imgB64;
  double strength;
  double noise;

  int? width;
  int? height;

  // Prompt overrides
  bool isOverwritten;
  String overwrittenPrompt;

  // Single-time I2I Request overrides
  String? singleTimeImgB64;

  Map<String, dynamic> get payload {
    Map<String, dynamic> ret = {
      'width': width,
      'height': height,
      'strength': strength,
      'noise': noise
    };
    if (isOverwritten) {
      ret['prompt'] = overwrittenPrompt;
    }
    if (singleTimeImgB64 == null) {
      ret['image'] = imgB64;
    } else {
      ret['image'] = singleTimeImgB64;
      singleTimeImgB64 = null;
    }
    return ret;
  }

  String? get imgB64 {
    return singleTimeImgB64 ?? _imgB64;
  }

  set imgB64(String? input) {
    _imgB64 = input;
  }

  I2IConfig({
    String? image,
    this.strength = 0.5,
    this.noise = 0,
    this.isOverwritten = false,
    this.overwrittenPrompt = '',
  }) {
    _imgB64 = image;
  }
}
