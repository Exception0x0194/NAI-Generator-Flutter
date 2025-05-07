import 'dart:convert';
import 'dart:typed_data';

class VibeConfig {
  String imageB64;
  String fileName;
  double infoExtracted;
  double referenceStrength;

  VibeConfig({
    required this.imageB64,
    required this.fileName,
    required this.infoExtracted,
    required this.referenceStrength,
  });

  factory VibeConfig.fromBytes(
    Uint8List imageBytes,
    String fileName,
    double infoExtracted,
    double referenceStrength,
  ) {
    return VibeConfig(
      imageB64: base64Encode(imageBytes),
      fileName: fileName,
      infoExtracted: infoExtracted,
      referenceStrength: referenceStrength,
    );
  }
}
