import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nai_casrand/models/utils.dart';
import 'package:image/image.dart' as img;

import '../utils/metadata.dart';

const defaultMetadataContent =
    '{"Description": "👻👻👻", "Software": "NovelAI", "Source": "Stable Diffusion XL 9CC2F394", "Generation time": "11.4514", "Comment": "{\\"prompt\\": \\"👻👻👻\\", \\"steps\\": 28, \\"height\\": 1024, \\"width\\": 1024, \\"scale\\": 5, \\"uncond_scale\\": 1.0, \\"cfg_rescale\\": 0.0, \\"seed\\": \\"\\", \\"n_samples\\": 1, \\"hide_debug_overlay\\": false, \\"noise_schedule\\": \\"native\\", \\"legacy_v3_extend\\": false, \\"reference_information_extracted_multiple\\": [], \\"reference_strength_multiple\\": [], \\"sampler\\": \\"k_euler_ancestral\\", \\"controlnet_strength\\": 1.0, \\"controlnet_model\\": null, \\"dynamic_thresholding\\": false, \\"dynamic_thresholding_percentile\\": 0.999, \\"dynamic_thresholding_mimic_scale\\": 10.0, \\"sm\\": false, \\"sm_dyn\\": false, \\"skip_cfg_below_sigma\\": 0.0, \\"lora_unet_weights\\": null, \\"lora_clip_weights\\": null, \\"uc\\": \\"\\", \\"request_type\\": \\"PromptGenerateRequest\\", \\"signed_hash\\": \\"\\"}"}';

class OutputManager {
  Directory? outputFolder;
  // Image metadata erase
  bool metadataEraseEnabled = false;
  bool customMetadataEnabled = false;
  String customMetadataContent = defaultMetadataContent;
  // Output indexing
  DateTime _generationTimestamp = DateTime.now();
  int _generationIdx = 0;

  OutputManager({
    this.outputFolder,
    this.metadataEraseEnabled = false,
    this.customMetadataEnabled = false,
    this.customMetadataContent = defaultMetadataContent,
  });

  factory OutputManager.fromJson(Map<String, dynamic> json) {
    final outputPath = json['output_folder'];
    final Directory? outputFolder;
    if (!kIsWeb && Platform.isWindows && outputPath != null) {
      outputFolder = Directory(outputPath);
    } else {
      outputFolder = null;
    }
    return OutputManager(
      outputFolder: outputFolder,
      metadataEraseEnabled: json['metadata_erase_enabled'] ?? false,
      customMetadataEnabled: json['custom_metadata_enabled'] ?? false,
      customMetadataContent:
          json['custom_metadata_content'] ?? defaultMetadataContent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "metadata_erase_enabled": metadataEraseEnabled,
      "custom_metadata_enabled": customMetadataEnabled,
      "custom_metadata_content": customMetadataContent,
      "output_folder": outputFolder?.path,
    };
  }

  void updateTimestamp() {
    _generationTimestamp = DateTime.now();
  }

  bool handleResponse(http.Response response) {
    final archive = ZipDecoder().decodeBytes(response.bodyBytes);
    for (var file in archive) {
      if (file.name == "image_0.png") {
        saveOutput(file);
        return true;
      }
    }
    return false;
  }

  void saveOutput(ArchiveFile file) async {
    var imageBytes = file.content as Uint8List;
    if (metadataEraseEnabled) {
      var image = img.decodePng(imageBytes)!;
      // Convert to BMP first to erase metadata in PNG info chunk
      image = img.decodeBmp(img.encodeBmp(image))!;
      if (!customMetadataEnabled) {
        image = image.convert(numChannels: 3);
      } else {
        image = image.convert(numChannels: 4);
        image = await embedMetadata(image, customMetadataContent);
      }
      imageBytes = img.encodePng(image);
    }
    var filename =
        'nai-generated-${getTimestampDigits(_generationTimestamp)}-${_generationIdx.toString().padLeft(4, '0')}-${generateRandomFileName()}.png';
    saveBlob(imageBytes, filename, saveDir: outputFolder);
    _generationIdx++;
  }
}
