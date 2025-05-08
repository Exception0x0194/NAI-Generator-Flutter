import 'dart:convert'; // For utf8 encoding/decoding
import 'package:flutter/foundation.dart';
import 'package:png_chunks_extract/png_chunks_extract.dart' as png_extract;

class VibeConfigV4 {
  String fileName;
  Uint8List?
      imageBytes; // The original PNG bytes, stored for potential later use
  String vibeB64; // The extracted Base64 vibe string
  double referenceStrength;

  VibeConfigV4({
    required this.fileName,
    required this.vibeB64,
    required this.referenceStrength,
    this.imageBytes,
  });

  // The keyword used when embedding the data in the iTXt chunk
  static const String _expectedITXtKeyword = "NovelAI_Vibe_Encoding_Base64";

  factory VibeConfigV4.fromPngBytes(
    String fileName,
    Uint8List imageBytes,
    double referenceStrength,
  ) {
    final List<Map<String, dynamic>> chunks =
        png_extract.extractChunks(imageBytes);
    String? extractedVibeB64;

    for (final chunk in chunks) {
      if (chunk['name'] == 'iTXt') {
        final Uint8List iTXtData = chunk['data'] as Uint8List;

        try {
          int keywordEndIndex = iTXtData.indexOf(0);
          if (keywordEndIndex == -1) continue;
          String keyword = utf8.decode(iTXtData.sublist(0, keywordEndIndex));

          if (keyword == _expectedITXtKeyword) {
            int currentIndex = keywordEndIndex + 1;

            if (currentIndex >= iTXtData.length) continue;
            int compressionFlag = iTXtData[currentIndex++];
            if (compressionFlag != 0) {
              throw FormatException(
                  "Unsupported iTXt compression flag: $compressionFlag for keyword '$_expectedITXtKeyword'. Expected 0.");
            }

            if (currentIndex >= iTXtData.length) continue;
            currentIndex++; // Skip compression method byte

            int langTagEndIndex = iTXtData.indexOf(0, currentIndex);
            if (langTagEndIndex == -1) continue;
            currentIndex = langTagEndIndex + 1;

            int translatedKeywordEndIndex = iTXtData.indexOf(0, currentIndex);
            if (translatedKeywordEndIndex == -1) continue;
            currentIndex = translatedKeywordEndIndex + 1;

            if (currentIndex < iTXtData.length) {
              extractedVibeB64 = utf8.decode(iTXtData.sublist(currentIndex));
              break;
            } else {
              throw const FormatException(
                  "iTXt chunk for '$_expectedITXtKeyword' has an empty text field.");
            }
          }
        } catch (e) {
          if (kDebugMode) print("Error parsing a candidate iTXt chunk: $e");
          continue;
        }
      }
    }

    if (extractedVibeB64 != null) {
      return VibeConfigV4(
        fileName: fileName,
        vibeB64: extractedVibeB64,
        referenceStrength: referenceStrength,
        imageBytes: imageBytes,
      );
    } else {
      throw ArgumentError(
          "Required iTXt chunk with keyword '$_expectedITXtKeyword' not found in PNG image '$fileName'.");
    }
  }

  // 新增的工厂构造函数，用于 .naiv4vibe 文件
  factory VibeConfigV4.fromNaiV4VibeJson(
    String originalFileName, // 从文件选择器获取的文件名
    Map<String, dynamic> jsonData,
    double defaultReferenceStrength, // 如果JSON中没有strength，则使用此默认值
  ) {
    // 1. 提取 'name'，如果不存在则使用原始文件名
    String name = jsonData['name'] as String? ?? originalFileName;

    // 2. 提取 'strength'
    double strength = defaultReferenceStrength;
    final importInfo = jsonData['importInfo'] as Map<String, dynamic>?;
    if (importInfo != null && importInfo['strength'] != null) {
      final dynamic strengthValue = importInfo['strength'];
      if (strengthValue is double) {
        strength = strengthValue;
      } else if (strengthValue is int) {
        strength = strengthValue.toDouble();
      } else if (strengthValue is String) {
        strength = double.tryParse(strengthValue) ?? defaultReferenceStrength;
      }
    }

    // 3. 提取 'encoding' (Base64 vibe string)
    //    直接从 encodings 中取出一个 encoding 即可
    String? vibeB64String;
    final encodingsMap = jsonData['encodings'] as Map<String, dynamic>?;
    if (encodingsMap != null) {
      // 遍历 encodingsMap 来找到第一个有效的 'encoding' 字符串
      outerLoop:
      for (var modelKey in encodingsMap.keys) {
        final modelEncodings = encodingsMap[modelKey] as Map<String, dynamic>?;
        if (modelEncodings != null) {
          for (var typeKey in modelEncodings.keys) {
            final typeEncodingInfo =
                modelEncodings[typeKey] as Map<String, dynamic>?;
            if (typeEncodingInfo != null &&
                typeEncodingInfo.containsKey('encoding')) {
              final dynamic encodingValue = typeEncodingInfo['encoding'];
              if (encodingValue is String && encodingValue.isNotEmpty) {
                vibeB64String = encodingValue;
                break outerLoop; // 找到后即跳出所有循环
              }
            }
          }
        }
      }
    }

    if (vibeB64String == null) {
      throw ArgumentError(
          "Could not find a valid 'encoding' field in the .naiv4vibe JSON data for file '$originalFileName'.");
    }

    return VibeConfigV4(
      fileName: name, // 使用从JSON中提取的name，或原始文件名
      vibeB64: vibeB64String,
      referenceStrength: strength.clamp(0.0, 1.0), // 确保强度在有效范围内
      imageBytes: null, // .naiv4vibe 文件不包含图片预览
    );
  }
}
