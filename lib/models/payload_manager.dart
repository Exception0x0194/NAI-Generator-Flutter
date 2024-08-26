import 'configs/director_tool_config.dart';
import 'configs/prompt_config.dart';
import 'configs/i2i_config.dart';
import 'configs/vibe_config.dart';
import 'configs/param_config.dart';

class PayloadInfo {
  Map<String, dynamic> payload = {};
  String comment = "";

  PayloadInfo({
    this.payload = const {},
    this.comment = "",
  });
}

class PayloadManager {
  PromptConfig promptConfig = PromptConfig();
  I2IConfig i2iConfig = I2IConfig();
  List<VibeConfig> vibeConfigs = [];
  ParamConfig paramConfig = ParamConfig();

  DirectorToolConfig directorToolConfig =
      DirectorToolConfig(type: "emotion", width: 1024, height: 1024, defry: 0);

  PayloadManager({
    required this.promptConfig,
    required this.paramConfig,
  });

  factory PayloadManager.fromJson(Map<String, dynamic> json) {
    return PayloadManager(
        promptConfig: PromptConfig.fromJson(json["prompt_config"], 0),
        paramConfig: ParamConfig.fromJson(json["param_config"]));
  }

  Map<String, dynamic> toJson() {
    return {
      "prompt_config": promptConfig.toJson(),
      "param_config": paramConfig.toJson()
    };
  }

  PayloadInfo getPayload() {
    // Director tools config
    if (directorToolConfig.imageB64 != null) {
      final directorToolPayload = directorToolConfig.getPayload();
      String comment = 'Director Tool: ${directorToolConfig.type}\n';
      if (directorToolConfig.overrideEnabled) {
        // Prompt is overritten in tool config
        comment += '<Prompt overritten>';
      } else {
        var pickedPrompts = promptConfig.pickPromptsFromConfig();
        var prompts = pickedPrompts['head']! + pickedPrompts['tail']!;
        directorToolPayload['prompt'] += prompts;
        comment += pickedPrompts['comment'] ?? '';
      }
      return PayloadInfo(payload: directorToolPayload, comment: comment);
    }

    // I2I config
    var pickedPrompts = promptConfig.pickPromptsFromConfig();
    var prompts = pickedPrompts['head']! + pickedPrompts['tail']!;

    var parameters = paramConfig.toJson();
    var action = 'generate';

    // Add vibe configs
    for (var config in vibeConfigs) {
      parameters['reference_image_multiple'].add(config.imageB64);
      parameters['reference_information_extracted_multiple']
          .add(config.infoExtracted);
      parameters['reference_strength_multiple'].add(config.referenceStrength);
    }

    // Add I2I configs
    var i2iPayload = i2iConfig.toJson();
    if (i2iPayload != null) {
      action = i2iPayload['action'];
      prompts = i2iPayload['input'] ?? prompts;
      parameters.addAll(i2iPayload['parameters']);
    }

    /// TODO: specify model in param config
    return PayloadInfo(
      payload: {
        "input": prompts,
        "model": "nai-diffusion-3",
        "action": action,
        "parameters": parameters,
      },
      comment: pickedPrompts['comment'] ?? "",
    );
  }
}
