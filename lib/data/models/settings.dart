const defaultWatermarkContent =
    '{"Description": "👻👻👻", "Software": "NovelAI", "Source": "Stable Diffusion XL 9CC2F394", "Generation time": "11.4514", "Comment": "{\\"prompt\\": \\"👻👻👻\\", \\"steps\\": 28, \\"height\\": 1024, \\"width\\": 1024, \\"scale\\": 5, \\"uncond_scale\\": 1.0, \\"cfg_rescale\\": 0.0, \\"seed\\": \\"\\", \\"n_samples\\": 1, \\"hide_debug_overlay\\": false, \\"noise_schedule\\": \\"native\\", \\"legacy_v3_extend\\": false, \\"reference_information_extracted_multiple\\": [], \\"reference_strength_multiple\\": [], \\"sampler\\": \\"k_euler_ancestral\\", \\"controlnet_strength\\": 1.0, \\"controlnet_model\\": null, \\"dynamic_thresholding\\": false, \\"dynamic_thresholding_percentile\\": 0.999, \\"dynamic_thresholding_mimic_scale\\": 10.0, \\"sm\\": false, \\"sm_dyn\\": false, \\"skip_cfg_below_sigma\\": 0.0, \\"lora_unet_weights\\": null, \\"lora_clip_weights\\": null, \\"uc\\": \\"\\", \\"request_type\\": \\"PromptGenerateRequest\\", \\"signed_hash\\": \\"\\"}"}';

class Settings {
  // Don't show again
  String welcomeMessageVersion;

  // API key
  String apiKey;

  // Output dir, for windows only
  String outputFolderPath;

  // Proxy settings
  String proxy;

  // Debug API path
  String debugApiPath;
  bool debugApiEnabled;

  // Image metadata erase
  bool metadataEraseEnabled;
  bool customMetadataEnabled;
  String customMetadataContent;

  // Batch settings
  int batchCount;
  int batchIntervalSec;
  // Number of requests
  int numberOfRequests;

  Settings(
      {required this.welcomeMessageVersion,
      required this.apiKey,
      required this.outputFolderPath,
      required this.proxy,
      required this.debugApiEnabled,
      required this.debugApiPath,
      required this.metadataEraseEnabled,
      required this.customMetadataEnabled,
      required this.customMetadataContent,
      required this.batchCount,
      required this.batchIntervalSec,
      required this.numberOfRequests});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      welcomeMessageVersion: json['welcome_message_version'] ?? '',
      apiKey: json['api_key'] ?? 'pst-abcd',
      outputFolderPath: json['output_folder'] ?? '',
      proxy: json['proxy'] ?? '',
      debugApiEnabled: false,
      debugApiPath: 'http://localhost:5000/ai/generate-image',
      metadataEraseEnabled: json['metadata_erase_enabled'] ?? false,
      customMetadataEnabled: json['custom_metadata_enabled'] ?? false,
      customMetadataContent:
          json['custom_metadata_content'] ?? defaultWatermarkContent,
      batchCount: json['batch_count'] ?? 10,
      batchIntervalSec: json['batch_interval'] ?? 10,
      numberOfRequests: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'welcome_message_version': welcomeMessageVersion,
      'api_key': apiKey,
      'output_folder': outputFolderPath,
      'proxy': proxy,
      'metadata_erase_enabled': metadataEraseEnabled,
      'custom_metadata_enabled': customMetadataEnabled,
      'custom_metadata_content': customMetadataContent,
      'batch_count': batchCount,
      'batch_interval': batchIntervalSec,
    };
  }
}
