import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // 用于处理JSON操作
import '../models/prompt_config.dart'; // 导入PromptConfig模型

class PromptConfigWidget extends StatefulWidget {
  final PromptConfig config;
  final int indentLevel;

  const PromptConfigWidget({
    super.key,
    required this.config,
    required this.indentLevel,
  });

  @override
  _PromptConfigWidgetState createState() => _PromptConfigWidgetState();
}

class _PromptConfigWidgetState extends State<PromptConfigWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: widget.indentLevel * 20.0),
      child: ExpansionTile(
        title: Row(children: [
          Expanded(child: Text(widget.config.comment)),
          Expanded(
              child: ListTile(
            leading: const Icon(Icons.download),
            title: const SizedBox.shrink(),
            onTap: () => {},
          )),
        ]),
        children: [
          Padding(
            padding: EdgeInsets.only(left: widget.indentLevel * 20.0 + 20),
            child: Column(
              children: [
                _buildCommentInput(),
                _buildSelectionMethodSelector(),
                _buildTypeSelector(),
                _buildInputProb(),
                _buildInputNum(),
                _buildShuffled(),
                _buildStrsExpansion(),
                _buildConfigsExpansion(),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget builders
  Widget _buildTypeSelector() {
    return ListTile(
      title: const Text('Type'),
      trailing: DropdownButton<String>(
        value: widget.config.type,
        onChanged: (String? newValue) {
          setState(() {
            widget.config.type = newValue!;
          });
        },
        items: <String>['config', 'str'] // 根据需要添加更多类型
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectionMethodSelector() {
    return ListTile(
      title: const Text('Selection Method'),
      trailing: DropdownButton<String>(
        value: widget.config.selectionMethod,
        onChanged: (String? newValue) {
          setState(() {
            widget.config.selectionMethod = newValue!;
          });
        },
        items: <String>['all', 'single', 'multiple_prob', 'multiple_num']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCommentInput() {
    return ListTile(
      title: const Text('Comment'),
      subtitle: Text(widget.config.comment),
      onTap: () {
        _editComment();
      },
    );
  }

  Widget _buildInputProb() {
    return widget.config.selectionMethod == 'multiple_prob'
        ? ListTile(
            title: const Text('Prob'),
            subtitle: Text(widget.config.prob.toStringAsFixed(2)),
            onTap: () {
              _editInputProb();
            },
          )
        : const SizedBox.shrink();
  }

  Widget _buildInputNum() {
    return widget.config.selectionMethod == 'multiple_num'
        ? ListTile(
            title: const Text('Num'),
            subtitle: Text(widget.config.num.toString()),
            onTap: () {
              _editInputNum();
            },
          )
        : const SizedBox.shrink();
  }

  // Edit functions
  void _editComment() {
    TextEditingController controller =
        TextEditingController(text: widget.config.comment);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: controller,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  widget.config.comment = controller.text;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _editInputProb() {
    TextEditingController controller =
        TextEditingController(text: widget.config.prob.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Probability'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  widget.config.prob =
                      double.tryParse(controller.text) ?? widget.config.prob;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _editInputNum() {
    TextEditingController controller =
        TextEditingController(text: widget.config.num.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Number'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  widget.config.num =
                      int.tryParse(controller.text) ?? widget.config.num;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildShuffled() {
    return ListTile(
      title: const Text('Shuffled'),
      trailing: Switch(
        value: widget.config.shuffled,
        onChanged: (bool val) {
          setState(() {
            widget.config.shuffled = val;
          });
        },
      ),
    );
  }

  Widget _buildStrsExpansion() {
    return widget.config.type == 'str'
        ? ExpansionTile(
            title: const Text('Strings'),
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: ListTile(
                    subtitle: Text(widget.config.strs.join('\n')),
                    onTap: () {
                      _editStrList();
                    },
                  ))
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _buildConfigsExpansion() {
    return widget.config.type == 'config'
        ? ExpansionTile(
            title: const Text('Configs'),
            children: [
              ...widget.config.prompts.map((config) => PromptConfigWidget(
                    config: config,
                    indentLevel: widget.indentLevel + 1,
                  )),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Add Config'),
                      onTap: () => _addNewConfig(),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Import from clipboard'),
                      onTap: () async {
                        await _importConfigFromClipboard();
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.remove),
                      title: const Text('Remove Config'),
                      onTap: () => _removeConfig(),
                    ),
                  ),
                ],
              )
            ],
          )
        : const SizedBox.shrink();
  }

  void _editStrList() {
    TextEditingController controller =
        TextEditingController(text: widget.config.strs.join('\n'));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Strings'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            maxLines: null, // 允许无限行
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  widget.config.strs = controller.text
                      .split('\n')
                      .where((str) => str.isNotEmpty)
                      .toList();
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewConfig() async {
    int? position = await _promptForPosition();
    if (position == null) {
      return;
    }

    setState(() {
      var newConfig = PromptConfig(
        selectionMethod: 'all',
        shuffled: true,
        prob: 0.0,
        num: 1,
        randomBrackets: 0,
        type: 'str',
        comment: 'New config',
        filter: '',
        depth: widget.config.depth + 1,
        strs: [],
        prompts: [],
      );

      if (position >= 0 && position <= widget.config.prompts.length) {
        widget.config.prompts.insert(position, newConfig);
      } else {
        widget.config.prompts.add(newConfig); // 如果位置无效，添加到末尾
      }
    });
  }

  void _removeConfig() async {
    int? position = await _promptForPosition();
    if (position == null) {
      return;
    }

    setState(() {
      if (position >= 0 && position < widget.config.prompts.length) {
        widget.config.prompts.removeAt(position);
      } else {
        widget.config.prompts.removeLast();
      }
    });
  }

  Future<void> _importConfigFromClipboard() async {
    int? position = await _promptForPosition();
    if (position == null) {
      return;
    }

    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      try {
        final Map<String, dynamic> jsonConfig = json.decode(data.text!);
        final newConfig = PromptConfig.fromJson(jsonConfig, 0);

        setState(() {
          if (position >= 0 && position <= widget.config.prompts.length) {
            widget.config.prompts.insert(position, newConfig);
          } else {
            widget.config.prompts.add(newConfig); // 如果位置无效，添加到末尾
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Config imported successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to import config')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No data in clipboard')));
    }
  }

  Future<int?> _promptForPosition() async {
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text("Enter position - start from 0"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                hintText: "Position (leave blank for end)"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                final position = int.tryParse(controller.text);
                Navigator.of(context).pop(position ?? -1);
              },
            ),
          ],
        );
      },
    );
  }
}
