import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class I2IConfig {
  img.Image? inputImage;
  bool isOverwritten;
  String overwrittenPrompt;
  double strength;
  double noise;

  I2IConfig({
    this.inputImage,
    this.strength = 0,
    this.noise = 0,
    this.isOverwritten = false,
    this.overwrittenPrompt = '',
  });

  I2IConfig? createWithFile(Uint8List imageBytes,
      {double strength = 0,
      double noise = 0,
      bool isOverwritten = false,
      String overwrittenPrompt = ''}) {
    var decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return null;

    return I2IConfig(
        inputImage: decodedImage,
        strength: strength,
        noise: noise,
        isOverwritten: isOverwritten,
        overwrittenPrompt: overwrittenPrompt);
  }

  String getInputB64(int width, int height) {
    var resizedImage =
        img.copyResize(inputImage!, width: width, height: height);
    return base64Encode(img.encodePng(resizedImage));
  }
}
