import 'package:NAI_CasRand/models/info_manager.dart';
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
      padding: EdgeInsets.only(left: widget.indentLevel * 10.0),
      child: ExpansionTile(
        leading: const Icon(Icons.arrow_forward),
        initiallyExpanded: widget.indentLevel == 0,
        title: Row(children: [
          Expanded(
              child: Row(children: [
            Text(widget.config.comment +
                (widget.config.enabled ? "" : " - disabled")),
            IconButton(
                onPressed: () => _showEditCommentDialog(context),
                icon: const Icon(Icons.edit))
          ])),
          Switch(
              value: widget.config.enabled,
              onChanged: (value) => {
                    setState(() {
                      widget.config.enabled = value;
                    })
                  }),
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
            padding: EdgeInsets.only(left: widget.indentLevel * 10.0 + 10),
            child: Column(
              children: InfoManager().showPromptParameters
                  ? [
                      // _buildCommentInput(),
                      _buildSelectionMethodSelector(),
                      _buildShuffled(),
                      _buildInputProb(),
                      _buildInputNum(),
                      _buildRandomBrackets(),
                      _buildTypeSelector(),
                      _buildStrsExpansion(),
                      _buildConfigsExpansion(),
                    ]
                  : _buildDirectChildList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSelectionMethodSelector() {
    return SelectableListTile(
      title: 'Selection Method',
      currentValue: widget.config.selectionMethod,
      options: const ['all', 'single', 'multiple_prob', 'multiple_num'],
      onSelectComplete: (value) =>
          setState(() => widget.config.selectionMethod = value),
      leading: const Icon(Icons.select_all),
      dense: true,
    );
  }

  _buildTypeSelector() {
    return SelectableListTile(
      title: 'Config Type',
      currentValue: widget.config.type,
      options: const ['str', 'config'],
      onSelectComplete: (value) => setState(() => widget.config.type = value),
      leading: const Icon(Icons.type_specimen),
      dense: true,
    );
  }

  Widget _buildCommentInput() {
    return EditableListTile(
      leading: const Icon(Icons.comment),
      title: "Comment",
      currentValue: widget.config.comment,
      onEditComplete: (value) => setState(() => widget.config.comment = value),
      keyboardType: TextInputType.text,
      dense: true,
    );
  }

  Widget _buildInputProb() {
    return widget.config.selectionMethod == 'multiple_prob'
        ? EditableListTile(
            leading: const Icon(Icons.question_mark),
            title: "Prob",
            currentValue: widget.config.prob.toString(),
            onEditComplete: (value) => setState(() => widget.config.prob =
                double.tryParse(value) ?? widget.config.prob),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            dense: true,
          )
        : const SizedBox.shrink();
  }

  Widget _buildInputNum() {
    return widget.config.selectionMethod == 'multiple_num'
        ? EditableListTile(
            leading: const Icon(Icons.question_mark),
            title: "Num",
            currentValue: widget.config.num.toString(),
            onEditComplete: (value) => setState(() =>
                widget.config.num = int.tryParse(value) ?? widget.config.num),
            keyboardType: TextInputType.number,
            dense: true,
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
            leading: const Icon(Icons.text_snippet),
            title: const Text('Strings'),
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10.0),
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
            leading: const Icon(Icons.arrow_downward),
            initiallyExpanded: widget.indentLevel == 0,
            title: const Text('Configs'),
            children: [
              ...widget.config.prompts.map((config) => PromptConfigWidget(
                    config: config,
                    indentLevel: widget.indentLevel + 1,
                  )),
              ListTile(
                  title: Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: 'Add New Config',
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addNewConfig(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Tooltip(
                      message: 'Import from Clipboard',
                      child: IconButton(
                        icon: const Icon(Icons.paste),
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
                        icon: const Icon(Icons.remove),
                        onPressed: () => _removeConfig(),
                      ),
                    ),
                  ),
                ],
              ))
            ],
          )
        : const SizedBox.shrink();
  }

  _buildRandomBrackets() {
    return EditableListTile(
      leading: const Icon(Icons.code),
      title: "Random Brackets",
      currentValue: widget.config.randomBrackets.toString(),
      onEditComplete: (value) => setState(() => widget.config.randomBrackets =
          int.tryParse(value) ?? widget.config.randomBrackets),
      keyboardType: TextInputType.number,
      dense: true,
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
      secondary: const Icon(Icons.shuffle),
      title: Text(title),
      value: currentValue,
      onChanged: onChanged,
      subtitle: Text(currentValue ? "Enabled" : "Disabled"),
      dense: true,
    );
  }

  void _showEditCommentDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.config.comment);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            maxLines: null,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.config.comment = controller.text;
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildDirectChildList() {
    if (widget.config.type == 'str') {
      return [
        ExpansionTile(
          leading: const Icon(Icons.text_snippet),
          title: const Text('Strings'),
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ListTile(
                  subtitle: Text(widget.config.strs.join('\n')),
                  onTap: () {
                    _editStrList();
                  },
                ))
          ],
        )
      ];
    } else {
      return [
        ...widget.config.prompts.map((config) => PromptConfigWidget(
              config: config,
              indentLevel: widget.indentLevel + 1,
            )),
        ListTile(
            title: Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Add New Config',
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addNewConfig(),
                ),
              ),
            ),
            Expanded(
              child: Tooltip(
                message: 'Import from Clipboard',
                child: IconButton(
                  icon: const Icon(Icons.paste),
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
                  icon: const Icon(Icons.remove),
                  onPressed: () => _removeConfig(),
                ),
              ),
            ),
          ],
        ))
      ];
    }
  }
}
