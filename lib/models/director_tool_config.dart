import 'dart:math';

class DirectorToolConfig {
  String? imageB64;

  String type = "emotion";
  List<String> emotions = ["neutral"];

  int width = 0;
  int height = 0;

  int defry = 0;

  Map<String, dynamic> toJson() {
    return {
      "req_type": type,
      "emotion": emotions,
      "defry": defry,
      "width": width,
      "height": height,
      "image": imageB64,
    };
  }

  Map<String, dynamic> getPayload() {
    return {
      "req_type": type,
      "prompt": type == "emotion"
          ? "${emotions[Random().nextInt(emotions.length)]};;"
          : "",
      "defry": defry,
      "width": width,
      "height": height,
      "image": imageB64,
    };
  }

  DirectorToolConfig(
      {required this.type,
      required this.width,
      required this.height,
      required this.defry,
      this.imageB64});
}
