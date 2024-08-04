import 'dart:math';

class DirectorToolConfig {
  String? imageB64;

  String type = "emotion";
  List<String> emotions = ["neutral"];

  int width = 0;
  int height = 0;

  bool overrideEnabled = false;
  String overridePrompt = "";

  int defry = 0;

  bool get withPrompt {
    return ['colorize', 'emotion'].contains(type);
  }

  Map<String, dynamic> toJson() {
    return {
      "req_type": type,
      "emotion": emotions,
      "defry": defry,
      "width": width,
      "height": height,
      "image": imageB64,
      "override_enabled": overrideEnabled,
      "override_prompt": overridePrompt,
    };
  }

  Map<String, dynamic> getPayload() {
    if (withPrompt) {
      var prompt = type == "emotion"
          ? "${emotions[Random().nextInt(emotions.length)]};;"
          : "";
      if (overrideEnabled) prompt += overridePrompt;
      return {
        "req_type": type,
        "prompt": prompt,
        "defry": defry,
        "width": width,
        "height": height,
        "image": imageB64,
      };
    } else {
      return {
        "req_type": type,
        "width": width,
        "height": height,
        "image": imageB64,
      };
    }
  }

  DirectorToolConfig(
      {required this.type,
      required this.width,
      required this.height,
      required this.defry,
      this.imageB64});
}
