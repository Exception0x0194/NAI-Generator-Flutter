import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class VibeConfig {
  img.Image inputImage;
  String imageB64;
  double infoExtracted;
  double referenceStrength;

  VibeConfig({
    required this.inputImage,
    required this.imageB64,
    required this.infoExtracted,
    required this.referenceStrength,
  });

  static VibeConfig? createWithFile(
      Uint8List imageBytes, double infoExtracted, double referenceStrength) {
    var originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      return null;
    }

    var width = originalImage.width, height = originalImage.height;
    double aspectRatio = 1.0 * width / height;

    if (aspectRatio > 1) {
      width = 448;
      height = (448 / aspectRatio).floor();
    } else {
      height = 448;
      width = (448 * aspectRatio).floor();
    }

    img.Image resizedImage = img.copyResize(originalImage,
        width: width, height: height, interpolation: img.Interpolation.average);
    resizedImage =
        img.copyExpandCanvas(resizedImage, newWidth: 448, newHeight: 448);

    return VibeConfig(
      inputImage: resizedImage,
      imageB64: base64Encode(img.encodePng(resizedImage)),
      infoExtracted: infoExtracted,
      referenceStrength: referenceStrength,
    );
  }
}
