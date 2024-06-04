import 'dart:math';

class PromptConfig {
  String selectionMethod;
  bool shuffled;
  double prob;
  int num;
  int randomBrackets;
  String type;
  String comment;
  String filter;
  int depth;
  List<String> strs;
  List<PromptConfig> prompts;
  bool enabled;

  int sequentialIdx = 0;

  PromptConfig({
    this.selectionMethod = 'all',
    this.shuffled = true,
    this.prob = 0.0,
    this.num = 1,
    this.randomBrackets = 0,
    this.type = 'str',
    this.comment = 'Unnamed config',
    this.filter = '',
    this.depth = 0,
    this.strs = const [],
    this.prompts = const [],
    this.enabled = true,
  });

  factory PromptConfig.fromJson(Map<String, dynamic> json, int depth) {
    return PromptConfig(
      selectionMethod: json['selectionMethod'],
      shuffled: json['shuffled'],
      prob:
          json['prob'] is int ? (json['prob'] as int).toDouble() : json['prob'],
      num: json['num'],
      randomBrackets: json['randomBrackets'],
      type: json['type'],
      comment: json['comment'],
      filter: json['filter'],
      depth: depth,
      strs:
          (json['strs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      prompts: (json['prompts'] as List<dynamic>?)
              ?.map((e) => PromptConfig.fromJson(e, depth + 1))
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
      'randomBrackets': randomBrackets,
      'type': type,
      'comment': comment,
      'filter': filter,
      'depth': depth,
      'strs': strs,
      'prompts': prompts.map((x) => x.toJson()).toList(),
      'enabled': enabled,
    };
  }

  String addBrackets(String s) {
    if (randomBrackets == 0) {
      return s;
    }
    List<String> brackets =
        Random().nextDouble() > 0.5 ? ["[", "]"] : ["{", "}"];
    final n = Random().nextInt(randomBrackets + 1);
    final bracketString = List.from(brackets.map((b) => b * n));
    return bracketString[0] + s + bracketString[1];
  }

  Map<String, String> pickPromptsFromConfig() {
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
        chosenPrompts = [toChoosePrompts[sequentialIdx]];
        sequentialIdx = (sequentialIdx + 1) % toChoosePrompts.length;
        break;
      default:
        chosenPrompts = List.from(toChoosePrompts);
    }

    if (shuffled) {
      chosenPrompts.shuffle();
    }

    for (var p in chosenPrompts) {
      if (type == 'str') {
        if (p.contains('|||')) {
          var parts = p.split('|||');
          head = '${addBrackets(parts[0])}, $head';
          tail = '$tail${addBrackets(parts[1])}, ';
        } else {
          tail = '$tail${addBrackets(p)}, ';
        }
      } else if (type == 'config') {
        var subPromptConfig = p as PromptConfig;
        var result = subPromptConfig.pickPromptsFromConfig();
        if (result['head']!.isNotEmpty) {
          head = '${result['head']}$head';
        }
        if (result['tail']!.isNotEmpty) {
          tail = '$tail${result['tail']}';
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
}
