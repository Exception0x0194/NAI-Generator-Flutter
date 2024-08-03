import 'dart:typed_data';

import 'package:image_size_getter/image_size_getter.dart';

class GenerationInfo {
  Uint8List? _imageBytes;
  int? width, height;

  Map<String, dynamic> displayInfo;

  GenerationInfo({required this.displayInfo, Uint8List? imageBytes}) {
    if (imageBytes != null) {
      _imageBytes = imageBytes;
      final size = ImageSizeGetter.getSize(MemoryInput(imageBytes));
      width = size.width;
      height = size.height;
    }
  }

  Uint8List? get imageBytes {
    return _imageBytes;
  }

  set imageBytes(Uint8List? imageBytes) {
    if (imageBytes == null) {
      _imageBytes = null;
      width = height = null;
      return;
    }
    _imageBytes = imageBytes;
    final size = ImageSizeGetter.getSize(MemoryInput(imageBytes));
    width = size.width;
    height = size.height;
  }
}
