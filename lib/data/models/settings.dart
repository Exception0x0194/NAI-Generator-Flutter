import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:nai_casrand/core/constants/settings.dart';

import '../../core/constants/defaults.dart';

class Settings {
  // Don't show again
  String welcomeMessageVersion;

  // Display settings
  int generationPageColumnCount;
  String themeMode;

  // API key
  String apiKey;

  static const defaultApiEndpoint =
      'https://image.novelai.net/ai/generate-image';
  String apiEndpoint;

  static bool isValidApiEndpoint(String value) {
    final endpoint = value.trim();
    if (endpoint.isEmpty) return true;
    final uri = Uri.tryParse(endpoint);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        !uri.hasFragment &&
        !RegExp(r'\s').hasMatch(endpoint);
  }

  String get generationEndpoint {
    if (debugApiEnabled) return debugApiPath;
    final endpoint = apiEndpoint.trim();
    if (!isValidApiEndpoint(endpoint)) {
      throw const FormatException(
          'Invalid API endpoint: expected an HTTP(S) URL.');
    }
    return endpoint.isEmpty ? defaultApiEndpoint : endpoint;
  }

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

  // File name prefix key
  String fileNamePrefixKey;

  Settings({
    required this.welcomeMessageVersion,
    required this.apiKey,
    this.apiEndpoint = '',
    required this.outputFolderPath,
    required this.proxy,
    required this.debugApiEnabled,
    required this.debugApiPath,
    required this.metadataEraseEnabled,
    required this.customMetadataEnabled,
    required this.customMetadataContent,
    required this.batchCount,
    required this.batchIntervalSec,
    required this.numberOfRequests,
    required this.fileNamePrefixKey,
    required this.generationPageColumnCount,
    required this.themeMode,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      welcomeMessageVersion: json['welcome_message_version'] ?? '',
      apiKey: json['api_key'] ?? 'pst-abcd',
      apiEndpoint: (json['api_endpoint'] as String? ?? '').trim(),
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
      numberOfRequests: json['number_of_requests'] ?? 0,
      fileNamePrefixKey: json['file_name_prefix_key'] ?? '',
      generationPageColumnCount: json['generation_page_column_count'] ?? 2,
      themeMode: json['theme_mode'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'welcome_message_version': welcomeMessageVersion,
      'api_key': apiKey,
      'api_endpoint': apiEndpoint,
      'output_folder': outputFolderPath,
      'proxy': proxy,
      'metadata_erase_enabled': metadataEraseEnabled,
      'custom_metadata_enabled': customMetadataEnabled,
      'custom_metadata_content': customMetadataContent,
      'batch_count': batchCount,
      'batch_interval': batchIntervalSec,
      'file_name_prefix_key': fileNamePrefixKey,
      'number_of_requests': numberOfRequests,
      'generation_page_column_count': generationPageColumnCount,
      'theme_mode': themeMode,
    };
  }

  AdaptiveThemeMode get theme =>
      stringToThemeMode[themeMode] ?? AdaptiveThemeMode.system;
}
