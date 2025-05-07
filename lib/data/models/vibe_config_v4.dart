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
}
