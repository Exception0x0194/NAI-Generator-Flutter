import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/prompt_config.dart';
import 'editable_list_tile.dart';

class PromptConfigWidget extends StatefulWidget {
  final PromptConfig config;
  final int indentLevel;

  const PromptConfigWidget({
    super.key,
    required this.config,
    required this.indentLevel,
  });

  @override
  PromptConfigWidgetState createState() => PromptConfigWidgetState();
}

class PromptConfigWidgetState extends State<PromptConfigWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: widget.indentLevel * 20.0),
      child: ExpansionTile(
        initiallyExpanded: widget.indentLevel == 0,
        title: Row(children: [
          Expanded(child: Text(widget.config.comment)),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: json.encode(widget.config.toJson())));
            },
            tooltip: 'Copy to Clipboard',
          ),
        ]),
        children: [
          Padding(
            padding: EdgeInsets.only(left: widget.indentLevel * 20.0 + 20),
            child: Column(
              children: [
                _buildCommentInput(),
                _buildSelectionMethodSelector(),
                _buildShuffled(),
                _buildInputProb(),
                _buildInputNum(),
                _buildRandomBrackets(),
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
    return EditableListTile(
      title: "Comment",
      currentValue: widget.config.comment,
      onEditComplete: (value) => setState(() => widget.config.comment = value),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildInputProb() {
    return widget.config.selectionMethod == 'multiple_prob'
        ? EditableListTile(
            title: "Prob",
            currentValue: widget.config.prob.toString(),
            onEditComplete: (value) => setState(() => widget.config.prob =
                double.tryParse(value) ?? widget.config.prob),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          )
        : const SizedBox.shrink();
  }

  Widget _buildInputNum() {
    return widget.config.selectionMethod == 'multiple_num'
        ? EditableListTile(
            title: "Num",
            currentValue: widget.config.prob.toString(),
            onEditComplete: (value) => setState(() =>
                widget.config.num = int.tryParse(value) ?? widget.config.num),
            keyboardType: TextInputType.number,
          )
        : const SizedBox.shrink();
  }

  Widget _buildShuffled() {
    return _buildSwitchTile("Shuffled", widget.config.shuffled, (newValue) {
      setState(() => widget.config.shuffled = newValue);
    });
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
            initiallyExpanded: widget.indentLevel == 0,
            title: const Text('Configs'),
            children: [
              ...widget.config.prompts.map((config) => PromptConfigWidget(
                    config: config,
                    indentLevel: widget.indentLevel + 1,
                  )),
              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: 'Add New Config',
                      child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addNewConfig(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Tooltip(
                      message: 'Import from Clipboard',
                      child: IconButton(
                        icon: Icon(Icons.paste),
                        onPressed: () async {
                          await _importConfigFromClipboard();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Tooltip(
                      message: 'Remove Config',
                      child: IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _removeConfig(),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        : const SizedBox.shrink();
  }

  _buildRandomBrackets() {
    return EditableListTile(
      title: "Random brackets",
      currentValue: widget.config.randomBrackets.toString(),
      onEditComplete: (value) => setState(() => widget.config.randomBrackets =
          int.tryParse(value) ?? widget.config.randomBrackets),
      keyboardType: TextInputType.number,
    );
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
    int? position = await _getInsertPosition();
    if (position == null) {
      return;
    }
    var newConfig = PromptConfig(comment: 'New config');

    setState(() {
      if (position >= 0 && position <= widget.config.prompts.length) {
        widget.config.prompts.insert(position, newConfig);
      } else {
        if (widget.config.prompts.isEmpty) {
          widget.config.prompts = [newConfig];
        } else {
          widget.config.prompts.add(newConfig); // 如果位置无效，添加到末尾
        }
      }
    });
  }

  void _removeConfig() async {
    int? position = await _getInsertPosition();
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
    int? position = await _getInsertPosition();
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
            if (widget.config.prompts.isEmpty) {
              widget.config.prompts = [newConfig];
            } else {
              widget.config.prompts.add(newConfig); // 如果位置无效，添加到末尾
            }
          }
        });
      } catch (e) {
        //
      }
    }
  }

  Future<int?> _getInsertPosition() async {
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

  Widget _buildSwitchTile(
      String title, bool currentValue, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: currentValue,
      onChanged: onChanged,
      subtitle: Text(currentValue ? "Enabled" : "Disabled"),
    );
  }
}
