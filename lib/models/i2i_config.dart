import 'dart:convert';
import 'dart:typed_data';

class I2IConfig {
  String? imgB64;
  double strength;
  double noise;
  bool isOverwritten;
  String overwrittenPrompt;
  double? scale;
  int? width;
  int? height;

  I2IConfig({
    this.imgB64,
    this.strength = 0.5,
    this.noise = 0,
    this.isOverwritten = false,
    this.overwrittenPrompt = '',
  });

  static createWithFile(Uint8List bytes) {
    return I2IConfig(imgB64: base64Encode(bytes));
  }
}
