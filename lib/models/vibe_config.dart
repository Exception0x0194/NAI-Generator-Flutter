import 'dart:convert';
import 'dart:typed_data';

class VibeConfig {
  String imageB64;
  double infoExtracted;
  double referenceStrength;

  VibeConfig({
    required this.imageB64,
    required this.infoExtracted,
    required this.referenceStrength,
  });

  static VibeConfig createWithFile(
      Uint8List imageBytes, double infoExtracted, double referenceStrength) {
    return VibeConfig(
      imageB64: base64Encode(imageBytes),
      infoExtracted: infoExtracted,
      referenceStrength: referenceStrength,
    );
  }
}
