import 'dart:convert';

import '../models/utils.dart';
import '../models/prompt_config.dart';
import '../generated/l10n.dart';
import 'editable_list_tile.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PromptConfigWidget extends StatefulWidget {
  final PromptConfig config;
  final int indentLevel;
  final bool showCompactView;

  const PromptConfigWidget({
    super.key,
    required this.config,
    required this.indentLevel,
    required this.showCompactView,
  });

  @override
  PromptConfigWidgetState createState() => PromptConfigWidgetState();
}

class PromptConfigWidgetState extends State<PromptConfigWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: widget.indentLevel == 0 ? 0 : 10.0),
      child: ExpansionTile(
        controlAffinity: ListTileControlAffinity.leading,
        initiallyExpanded: widget.indentLevel == 0,
        title: Row(children: [
          Text(widget.config.comment,
              style: TextStyle(
                decoration: widget.config.enabled
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              )),
          IconButton(
              onPressed: () => _showEditCommentDialog(context),
              icon: const Icon(Icons.edit))
        ]),
        // subtitle: widget.showCompactView
        //     ? Text(_getConfigDescrption())
        //     : const SizedBox.shrink(),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
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
              copyToClipboard(json.encode(widget.config.toJson()));
              showInfoBar(context,
                  '${S.of(context).info_export_to_clipboard}${S.of(context).succeed}');
            },
            tooltip: S.of(context).export_to_clipboard,
          )
        ]),
        children: widget.showCompactView
            ? _buildCompactChildList()
            : [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(children: [
                    _buildSelectionMethodSelector(),
                    _buildShuffled(),
                    _buildInputProb(),
                    _buildInputNum(),
                    _buildRandomBrackets(),
                    _buildTypeSelector(),
                    _buildStrsExpansion(),
                    _buildConfigsExpansion(),
                  ]),
                )
              ],
      ),
    );
  }

  Widget _buildSelectionMethodSelector() {
    return SelectableListTile(
      title: S.of(context).selection_method,
      currentValue: widget.config.selectionMethod,
      options: const [
        'all',
        'single',
        'single_sequential',
        'multiple_prob',
        'multiple_num'
      ],
      options_text: [
        S.of(context).selection_method_all,
        S.of(context).selection_method_single,
        S.of(context).selection_method_single_sequential,
        S.of(context).selection_method_multiple_prob,
        S.of(context).selection_method_multiple_num
      ],
      onSelectComplete: (value) =>
          setState(() => widget.config.selectionMethod = value),
      leading: const Icon(Icons.select_all),
    );
  }

  _buildTypeSelector({bool dense = false}) {
    return SelectableListTile(
      title: S.of(context).cascaded_config_type,
      currentValue: widget.config.type,
      options: const ['str', 'config'],
      options_text: [
        S.of(context).cascaded_strings,
        S.of(context).cascaded_config_type_config
      ],
      onSelectComplete: (value) => setState(() => widget.config.type = value),
      leading: const Icon(Icons.type_specimen),
      dense: dense,
    );
  }

  Widget _buildInputProb() {
    return widget.config.selectionMethod == 'multiple_prob'
        ? EditableListTile(
            leading: const Icon(Icons.question_mark),
            title: S.of(context).selection_prob,
            currentValue: widget.config.prob.toString(),
            onEditComplete: (value) => setState(() {
              var n = double.tryParse(value);
              if (n != null && 0 <= n && n <= 1) {
                widget.config.prob = n;
              }
            }),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            confirmOnSubmit: true,
          )
        : const SizedBox.shrink();
  }

  Widget _buildInputNum() {
    return widget.config.selectionMethod == 'multiple_num'
        ? EditableListTile(
            leading: const Icon(Icons.question_mark),
            title: S.of(context).selection_num,
            currentValue: widget.config.num.toString(),
            onEditComplete: (value) => setState(() {
              var n = int.tryParse(value);
              if (n != null && 0 <= n) {
                widget.config.num = n;
              }
            }),
            keyboardType: TextInputType.number,
            confirmOnSubmit: true,
          )
        : const SizedBox.shrink();
  }

  Widget _buildShuffled() {
    return (widget.config.selectionMethod == 'all' ||
            widget.config.selectionMethod == 'multiple_prob')
        ? _buildSwitchTile(S.of(context).shuffled, widget.config.shuffled,
            (newValue) {
            setState(() => widget.config.shuffled = newValue);
          })
        : const SizedBox.shrink();
  }

  Widget _buildStrsExpansion() {
    return widget.config.type == 'str'
        ? ExpansionTile(
            leading: const Icon(Icons.text_snippet),
            title: Text(S.of(context).cascaded_strings),
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
            title: Text(S.of(context).cascaded_configs),
            children: [
              ...widget.config.prompts.map((config) => PromptConfigWidget(
                    config: config,
                    indentLevel: widget.indentLevel + 1,
                    showCompactView: widget.showCompactView,
                  )),
              _buildButtonsRow()
            ],
          )
        : const SizedBox.shrink();
  }

  _buildRandomBrackets() {
    return ListTile(
      leading: const Icon(Icons.code),
      title: Text(S.of(context).random_brackets),
      subtitle: Text(
          '${widget.config.randomBracketsLower.toString()} ~ ${widget.config.randomBracketsUpper.toString()}'),
      onTap: _showEditBracketsDialog,
    );
  }

  void _showEditBracketsDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).select + S.of(context).random_brackets),
            content: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(S.of(context).select_bracket_hint),
                      RangeSlider(
                          values: RangeValues(
                              widget.config.randomBracketsLower.toDouble(),
                              widget.config.randomBracketsUpper.toDouble()),
                          labels: RangeLabels(
                              widget.config.randomBracketsLower
                                  .toInt()
                                  .toString(),
                              widget.config.randomBracketsUpper
                                  .toInt()
                                  .toString()),
                          min: -10,
                          max: 10,
                          divisions: 20,
                          onChanged: (range) {
                            setState(() {
                              widget.config.randomBracketsLower =
                                  range.start.toInt();
                              widget.config.randomBracketsUpper =
                                  range.end.toInt();
                            });
                            setDialogState(() {});
                          }),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            widget.config.randomBracketsUpper = 0;
                            widget.config.randomBracketsLower = 0;
                          });
                          setDialogState(() {});
                        },
                      )
                    ]);
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(S.of(context).confirm),
              ),
            ],
          );
        });
  }

  void _editStrList() {
    TextEditingController controller =
        TextEditingController(text: widget.config.strs.join('\n'));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${S.of(context).edit}${S.of(context).cascaded_strings}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            maxLines: null, // 允许无限行
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: Text(S.of(context).cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(S.of(context).confirm),
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
    var newConfig =
        PromptConfig(comment: 'New config', depth: widget.config.depth + 1);

    setState(() {
      if (widget.config.prompts.isNotEmpty) {
        widget.config.prompts.add(newConfig);
      } else {
        widget.config.prompts = [newConfig];
      }
    });
  }

  Future<void> _importConfigFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;

    if (data != null && data.text != null) {
      try {
        final Map<String, dynamic> jsonConfig = json.decode(data.text!);
        final newConfig = PromptConfig.fromJson(jsonConfig, 0);

        setState(() {
          if (widget.config.prompts.isEmpty) {
            widget.config.prompts = [newConfig];
          } else {
            widget.config.prompts.add(newConfig); // 如果位置无效，添加到末尾
          }
        });
      } catch (e) {
        showErrorBar(context,
            '${S.of(context).info_import_from_clipboard}${S.of(context).failed}');
      }
    }
  }

  Future<int?> _getInsertPosition() async {
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text(S.of(context).enter_position),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.of(context).notice_enter_positon),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) {
                    final position = int.tryParse(controller.text);
                    Navigator.of(context).pop(position ?? -1);
                  },
                  autofocus: true,
                )
              ]),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(S.of(context).confirm),
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
      subtitle:
          Text(currentValue ? S.of(context).enabled : S.of(context).disabled),
    );
  }

  void _showEditCommentDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.config.comment);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${S.of(context).edit}${S.of(context).comment}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            maxLines: null,
            onSubmitted: (_) {
              Navigator.of(context).pop();
              setState(() {
                widget.config.comment = controller.text;
              });
            },
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  widget.config.comment = controller.text;
                });
              },
              child: Text(S.of(context).confirm),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCompactChildList() {
    if (widget.config.type == 'str') {
      return [
        ListTile(
          title: Text(S.of(context).cascaded_strings),
          subtitle: Text(widget.config.strs.join('\n')),
          onTap: () {
            _editStrList();
          },
        ),
      ];
    } else {
      return [
        ...widget.config.prompts.map((config) => PromptConfigWidget(
            config: config,
            indentLevel: widget.indentLevel + 1,
            showCompactView: widget.showCompactView)),
        _buildButtonsRow()
      ];
    }
  }

  Widget _buildButtonsRow() {
    return ListTile(
        title: Row(
      children: [
        Expanded(
          child: Tooltip(
            message: S.of(context).add_new_config,
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addNewConfig(),
            ),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: S.of(context).import_config_from_clipboard,
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
            message: S.of(context).reorder_config,
            child: IconButton(
              icon: const Icon(Icons.cached),
              onPressed: () => _showReorderDialog(),
            ),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: S.of(context).delete_config,
            child: IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _showDeleteDialog(),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    ));
  }

  String _getConfigDescrption() {
    String ret = '';
    switch (widget.config.selectionMethod) {
      case 'all':
        ret += '${S.of(context).selection_method_all} / ';
        break;
      case 'single':
        ret += '${S.of(context).selection_method_single} / ';
        break;
      case 'single_sequential':
        ret += '${S.of(context).selection_method_single_sequential} / ';
        break;
      case 'multiple_num':
        ret +=
            '${S.of(context).selection_method_multiple_num}: ${widget.config.num} / ';
        break;
      case 'multiple_prob':
        ret +=
            '${S.of(context).selection_method_multiple_prob}: ${widget.config.prob} / ';
    }
    if (widget.config.selectionMethod == 'all' ||
        widget.config.selectionMethod == 'multiple_prob') {
      ret +=
          '${widget.config.shuffled ? S.of(context).is_shuffled : S.of(context).is_ordered} / ';
    }
    if (widget.config.type == 'str') {
      ret += S.of(context).cascaded_config_type_str;
    } else {
      ret += S.of(context).cascaded_config_type_config;
    }
    return ret;
  }

  void _showReorderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).reorder_config),
          content: SizedBox(
            width: double.maxFinite,
            height: 600,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      var item = widget.config.prompts.removeAt(oldIndex);
                      widget.config.prompts.insert(newIndex, item);
                    });
                    setDialogState(() {});
                  },
                  children:
                      List.generate(widget.config.prompts.length, (index) {
                    return ListTile(
                      key: ValueKey(widget.config.prompts[index]),
                      title: Text(widget.config.prompts[index].comment),
                      trailing: const Icon(Icons.drag_handle),
                    );
                  }),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).confirm),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).delete_config),
          content: SizedBox(
              width: double.maxFinite,
              height: 600,
              child: StatefulBuilder(builder: (context, setDialogState) {
                return ListView.builder(
                    itemCount: widget.config.prompts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Text(widget.config.prompts[index].comment),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() {
                                  widget.config.prompts.removeAt(index);
                                });
                                setDialogState(() {});
                              }));
                    });
              })),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).confirm),
            ),
          ],
        );
      },
    );
  }
}
