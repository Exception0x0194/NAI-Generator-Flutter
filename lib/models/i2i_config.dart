import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class I2IConfig {
  img.Image? inputImage;
  bool isOverwritten;
  String overwrittenPrompt;
  double strength;
  double noise;
  double? scale;

  I2IConfig({
    this.inputImage,
    this.strength = 0,
    this.noise = 0,
    this.isOverwritten = false,
    this.overwrittenPrompt = '',
  });

  // 异步方法用于从文件创建配置
  static Future<I2IConfig?> createWithFile(Uint8List imageBytes,
      {double strength = 0,
      double noise = 0,
      bool isOverwritten = false,
      String overwrittenPrompt = ''}) async {
    var decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return null;

    return I2IConfig(
        inputImage: decodedImage,
        strength: strength,
        noise: noise,
        isOverwritten: isOverwritten,
        overwrittenPrompt: overwrittenPrompt);
  }

  // 异步方法用于获取图像的Base64编码
  Future<String> getInputB64(int width, int height) async {
    var resizedImage =
        img.copyResize(inputImage!, width: width, height: height);
    return base64Encode(img.encodePng(resizedImage));
  }
}
