import 'dart:math';

class PromptResult {
  String prompt;
  String comment;

  PromptResult({
    required this.prompt,
    required this.comment,
  });
}

class PromptConfig {
  String selectionMethod;
  bool shuffled;
  double prob;
  int num;
  int randomBracketsUpper;
  int randomBracketsLower;
  String type;
  String comment;
  String filter;
  List<String> strs;
  List<PromptConfig> prompts;
  bool enabled;

  int _sequentialIdx = 0;
  int _sequentialRepeatIdx = 0;

  PromptConfig({
    this.selectionMethod = 'all',
    this.shuffled = true,
    this.prob = 0.0,
    this.num = 1,
    this.randomBracketsUpper = 0,
    this.randomBracketsLower = 0,
    this.type = 'str',
    this.comment = 'Unnamed config',
    this.filter = '',
    this.strs = const [],
    this.prompts = const [],
    this.enabled = true,
  });

  factory PromptConfig.fromJson(Map<String, dynamic> json) {
    int upper, lower;
    if (json['randomBrackets'] != null) {
      upper = json['randomBrackets'];
      lower = -json['randomBrackets'];
    } else {
      upper = json['randomBracketsUpper'];
      lower = json['randomBracketsLower'];
    }

    return PromptConfig(
      selectionMethod: json['selectionMethod'],
      shuffled: json['shuffled'],
      prob:
          json['prob'] is int ? (json['prob'] as int).toDouble() : json['prob'],
      num: json['num'],
      randomBracketsUpper: upper.toInt(),
      randomBracketsLower: lower.toInt(),
      type: json['type'],
      comment: json['comment'],
      filter: json['filter'],
      strs:
          (json['strs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      prompts: (json['prompts'] as List<dynamic>?)
              ?.map((e) => PromptConfig.fromJson(e))
              .toList() ??
          [],
      enabled: json['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectionMethod': selectionMethod,
      'shuffled': shuffled,
      'prob': prob,
      'num': num,
      'randomBracketsUpper': randomBracketsUpper,
      'randomBracketsLower': randomBracketsLower,
      'type': type,
      'comment': comment,
      'filter': filter,
      'strs': strs,
      'prompts': prompts.map((x) => x.toJson()).toList(),
      'enabled': enabled,
    };
  }

  String addRandomBrackets(String s) {
    int n = randomBracketsLower +
        Random().nextInt(randomBracketsUpper - randomBracketsLower + 1);
    List<String> brackets;

    if (n < 0) {
      brackets = ["[", "]"];
      n = -n;
    } else {
      brackets = ["{", "}"];
    }

    final bracketString = List.from(brackets.map((b) => b * n));
    return bracketString[0] + s + bracketString[1];
  }

  Map<String, String> _pickPromptsFromConfig({int depth = 0}) {
    String head = '', tail = '';
    String comment = '';

    List<dynamic> chosenPrompts = [];
    List<dynamic> toChoosePrompts = [];
    if (type == 'str') {
      toChoosePrompts = List.from(strs);
    } else if (type == 'config') {
      toChoosePrompts = List.from(prompts.where((p) => p.enabled));
    }
    final random = Random();

    switch (selectionMethod) {
      case 'single':
        if (toChoosePrompts.isNotEmpty) {
          chosenPrompts
              .add(toChoosePrompts[random.nextInt(toChoosePrompts.length)]);
        }
        break;
      case 'all':
        chosenPrompts = toChoosePrompts;
        break;
      case 'multiple_prob':
        chosenPrompts =
            toChoosePrompts.where((_) => random.nextDouble() < prob).toList();
        break;
      case 'multiple_num':
        chosenPrompts = List.from(toChoosePrompts);
        chosenPrompts.shuffle();
        chosenPrompts = chosenPrompts.take(num).toList();
        break;
      case 'single_sequential':
        chosenPrompts = [toChoosePrompts[_sequentialIdx]];
        _sequentialRepeatIdx++;
        if (_sequentialRepeatIdx >= num) {
          _sequentialIdx = (_sequentialIdx + 1) % toChoosePrompts.length;
          _sequentialRepeatIdx = 0;
        }
        break;
      default:
        chosenPrompts = List.from(toChoosePrompts);
    }

    if (shuffled) {
      chosenPrompts.shuffle();
    }

    for (var (idx, p) in chosenPrompts.indexed) {
      final sep = idx == chosenPrompts.length - 1 ? '' : ', ';
      if (type == 'str') {
        if (p.contains('|||')) {
          var parts = p.split('|||');
          head = '${addRandomBrackets(parts[0])}$sep$head';
          tail = '$tail${addRandomBrackets(parts[1])}$sep';
        } else {
          tail = '$tail${addRandomBrackets(p)}$sep';
        }
      } else if (type == 'config') {
        var subPromptConfig = p as PromptConfig;
        var result = subPromptConfig._pickPromptsFromConfig(depth: depth + 1);
        if (result['head'] != null && result['head']!.isNotEmpty) {
          head = '${addRandomBrackets(result['head']!)}$sep$head';
        }
        if (result['tail'] != null && result['tail']!.isNotEmpty) {
          tail = '$tail${addRandomBrackets(result['tail']!)}$sep';
        }
        comment += result['comment']!;
      }
    }
    if (type == 'str') comment += '$head$tail';

    if (head.isNotEmpty || tail.isNotEmpty) {
      comment =
          '${'--' * depth}${this.comment}:${type == 'config' ? '\n' : ' '}$comment${type == 'config' ? '' : '\n'}';
    }

    return {'head': head, 'tail': tail, 'comment': comment};
  }

  PromptResult getPrompt() {
    final prompts = _pickPromptsFromConfig();
    return PromptResult(
        prompt: '${prompts['head']}${prompts['tail']}',
        comment: prompts['comment'] ?? '');
  }
}
