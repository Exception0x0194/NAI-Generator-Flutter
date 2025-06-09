import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:archive/archive.dart';

class ImageService {
  /// Process response bytes and return image bytes
  Uint8List processResponse(Uint8List zippedResponseBytes) {
    try {
      var archive = ZipDecoder().decodeBytes(zippedResponseBytes);
      for (final file in archive) {
        if (file.name != 'image_0.png') continue;
        return file.content;
      }
      throw Exception('Image file image_0.png not found in archive.');
    } catch (e) {
      final bytes = zippedResponseBytes;
      throw Exception(
          'Error unpacking response: ${e.toString()};\nResponse data: ${bytes.length < 1000 ? utf8.decode(bytes) : '${bytes.length} bytes'}');
    }
  }

  Future<Uint8List> embedMetadata(
    Uint8List imageBytes,
    String metadataString,
  ) async {
    final image = img.decodePng(imageBytes);
    if (image == null) {
      throw Exception('Image decode failed while embedding metadata.');
    }
    final codec = GZipCodec();
    final magicBytes = utf8.encode("stealth_pngcomp");
    final encodedData = codec.encode(utf8.encode(metadataString));
    final bitLength = encodedData.length * 8;
    final bitLengthInBytes = ByteData(4);
    bitLengthInBytes.setInt32(0, bitLength);
    final dataToEmbed = [
      ...magicBytes,
      ...bitLengthInBytes.buffer.asUint8List(),
      ...encodedData
    ];

    var bitIndex = 0;
    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        final byteIndex = (bitIndex / 8).floor();
        if (byteIndex >= dataToEmbed.length) break;
        final bit = (dataToEmbed[byteIndex] >> (7 - bitIndex % 8)) & 1;
        final pixel = image.getPixel(x, y);
        pixel.a = 254 | bit;
        image.setPixel(x, y, pixel);
        bitIndex++;
      }
    }
    return img.encodePng(image);
  }

  Future<String?> extractMetadata(img.Image image) async {
    final magicBytes = utf8.encode("stealth_pngcomp");
    final List<int> extractedBytes = [];
    int bitIndex = 0;
    int byteValue = 0;

    // 读取整个图片中的数据位
    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final alpha = pixel.a as int;
        final bit = (alpha & 1);
        byteValue = (byteValue << 1) | bit;
        if (++bitIndex % 8 == 0) {
          extractedBytes.add(byteValue);
          byteValue = 0;
        }
      }
    }

    // 检查是否包含特定的魔法字节
    final magicByteLength = magicBytes.length;
    if (listEquals(extractedBytes.take(magicByteLength).toList(), magicBytes)) {
      // 读取数据长度
      final bitLengthBytes =
          extractedBytes.sublist(magicByteLength, magicByteLength + 4);
      final bitLength =
          ByteData.sublistView(Uint8List.fromList(bitLengthBytes)).getInt32(0);
      final dataLength = (bitLength / 8).ceil();

      // 读取实际数据并解压缩
      final compressedData = extractedBytes.sublist(
          magicByteLength + 4, magicByteLength + 4 + dataLength);
      final codec = GZipCodec();
      final decodedData = codec.decode(Uint8List.fromList(compressedData));
      return utf8.decode(decodedData);
    }

    return null; // 如果没有找到特定的魔法字节
  }
}
