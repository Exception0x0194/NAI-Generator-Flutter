import 'dart:convert';
import 'dart:io';
import 'dart:math';

class PromptConfig {
  String? selectionMethod;
  bool shuffled;
  double? prob;
  int? num;
  int? randomBrackets;
  String type;
  String comment;
  String? filter;
  int depth;
  List<dynamic> prompts = [];
  int seqIdx = 0;
  List<List<int>> seqList = [];

  PromptConfig(Map<String, dynamic> config, [this.depth = -1])
      : shuffled = config['shuffled'] ?? false,
        prob = config['prob'],
        num = config['num'] ?? config['select_n'],
        randomBrackets = config['random_brackets'],
        type = config['type'],
        comment = config['comment'] ?? "" {
    selectionMethod = config['selection_method'] ?? config['selection method'];

    if (type == 'config') {
      prompts = [
        for (var prompt in config['prompts']) PromptConfig(prompt, depth + 1)
      ];
    } else if (type == 'str') {
      prompts = config['prompts'];
    } else if (type == 'folder') {
      for (var pathPrefix in config['prompts']) {
        var dir = Directory(pathPrefix);
        List<FileSystemEntity> files = dir.listSync();
        for (var file in files) {
          prompts.add(file.path);
        }
      }
    } else if (type == 'import') {
      var configFileName = config['prompts'];
      var file = File(configFileName);
      var importedConfig = PromptConfig(jsonDecode(file.readAsStringSync()));
      for (var attr in importedConfig.toJson().keys) {
        if (!toJson().containsKey(attr) ||
            toJson()[attr] == null ||
            ['prompts', 'type'].contains(attr)) {
          toJson()[attr] = importedConfig.toJson()[attr];
        }
      }
    }

    if (selectionMethod == 'sequential' && prompts.isNotEmpty) {
      seqList = List<List<int>>.generate(
        prompts.length,
        (int index) => List<int>.generate(prompts.length, (int index) => index),
        growable: false,
      );
    }
  }

  String addBrackets(String s) {
    var brackets = Random().nextDouble() > 0.5 ? ["[", "]"] : ["{", "}"];
    var n = Random().nextInt(randomBrackets ?? 0);
    // brackets = [b * n for b in brackets];
    String b1 = brackets[0] * n;
    String b2 = brackets[1] * n;
    return b1 + s + b2;
  }

  Map<String, dynamic> pickPromptsFromConfig() {
    String prompt = "";
    String comment = "\n${"--" * depth}";

    if (shuffled) {
      prompts.shuffle();
    }

    List<dynamic> chosenPrompts;
    switch (selectionMethod) {
      case 'single':
        chosenPrompts = [prompts[Random().nextInt(prompts.length)]];
        break;
      case 'all':
        chosenPrompts = prompts;
        break;
      case 'multiple_prob':
        chosenPrompts =
            prompts.where((p) => Random().nextDouble() < prob!).toList();
        break;
      case 'multiple_num':
        chosenPrompts = List<dynamic>.from(prompts)..shuffle();
        chosenPrompts = chosenPrompts.sublist(0, num!);
        break;
      // case 'sequential':
      //   chosenPrompts = [prompts[idx] for idx in seqList[seqIdx]];
      //   seqIdx = (seqIdx + 1) % seqList.length;
      //   break;
      default:
        chosenPrompts = [];
        break;
    }

    if (comment.isNotEmpty) {
      comment += "${this.comment}: ";
    }

    for (var p in chosenPrompts) {
      if (type == 'str') {
        if (randomBrackets != null) {
          p = addBrackets(p);
        }
        prompt += "$p, ";
        comment += "$p, ";
      } else if (type == 'config') {
        var res = p.pickPromptsFromConfig();
        prompt += res['prompt'];
        comment += res['comment'];
      } 
      // else if (type == 'folder') {
      //   var file = File(p);
      //   var line = file.readAsLinesSync().first + ", ";
      //   prompt += line;
      //   comment += line;
      // }
    }

    if (filter == null || RegExp(filter!).hasMatch(prompt)) {
      return {'prompt': prompt, 'comment': comment};
    } else {
      return pickPromptsFromConfig();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'selectionMethod': selectionMethod,
      'shuffled': shuffled,
      'prob': prob,
      'num': num,
      'randomBrackets': randomBrackets,
      'type': type,
      'comment': comment,
      'filter': filter,
      'depth': depth,
      'prompts': prompts,
    };
  }
}

class PromptsGenerator {
  PromptConfig config;

  PromptsGenerator(Map<String, dynamic> jsonData)
      : config = PromptConfig(jsonData);

  PromptConfig getConfig() {
    return config;
  }

  Map<String, dynamic> getPrompt() {
    return config.pickPromptsFromConfig();
  }
}
