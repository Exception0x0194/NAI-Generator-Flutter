import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../models/utils.dart';
import '../models/prompt_config.dart';
import '../generated/l10n.dart';
import 'editable_list_tile.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompactPromptConfigWidget extends StatefulWidget {
  final PromptConfig config;
  final int indentLevel;

  const CompactPromptConfigWidget({
    super.key,
    required this.config,
    required this.indentLevel,
  });

  @override
  CompactPromptConfigWidgetState createState() =>
      CompactPromptConfigWidgetState();
}

class CompactPromptConfigWidgetState extends State<CompactPromptConfigWidget> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.config.enabled ? null : Colors.black.withAlpha(30);
    return Padding(
        padding: EdgeInsets.only(left: widget.indentLevel == 0 ? 0 : 20),
        child: ExpansionTile(
          // Title and config button
          title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                Text(widget.config.comment),
                TextButton(
                  child: Text(_getConfigDescrption()),
                  onPressed: () => _showConfigDialog(),
                )
              ])),
          // Enable / disable switch
          trailing: Switch(
            value: widget.config.enabled,
            onChanged: (value) => setState(() {
              widget.config.enabled = value;
            }),
          ),
          backgroundColor: backgroundColor,
          collapsedBackgroundColor: backgroundColor,
          controlAffinity: ListTileControlAffinity.leading,
          initiallyExpanded: (widget.indentLevel == 0),
          // Children
          children: _buildChildrenList(),
        ));
  }

  String _getConfigDescrption() {
    String ret = '';
    // Selection method-related parameters
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
    // Config type
    if (widget.config.type == 'str') {
      ret += S.of(context).cascaded_config_type_str;
    } else {
      ret += S.of(context).cascaded_config_type_config;
    }
    // Random brackets
    final lower = widget.config.randomBracketsLower;
    final upper = widget.config.randomBracketsUpper;
    if (lower != 0 || upper != 0) {
      ret += ' / ${lower.toString()} ~ ${upper.toString()}';
    }
    return ret;
  }

  List<Widget> _buildChildrenList() {
    if (widget.config.type == 'str') {
      return [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ListTile(
            title: Text(S.of(context).cascaded_strings),
            subtitle: Text(widget.config.strs.join('\n')),
            onTap: () {
              _editStrList();
            },
          ),
        )
      ];
    } else {
      return [
        ...widget.config.prompts.map((config) => CompactPromptConfigWidget(
            config: config, indentLevel: widget.indentLevel + 1)),
        _buildButtonsRow()
      ];
    }
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

  void _showConfigDialog() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
                scrollable: true,
                title: Row(children: [
                  Text('${S.of(context).edit} ${widget.config.comment}'),
                  const Spacer(),
                  IconButton(
                      onPressed: () => _showEditCommentDialog(setDialogState),
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {
                        copyToClipboard(json.encode(widget.config.toJson()));
                        showInfoBar(context,
                            '${S.of(context).info_export_to_clipboard}${S.of(context).succeed}');
                      },
                      icon: const Icon(Icons.copy))
                ]),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Sizedbox with max width to increase dialog's width
                  const SizedBox(width: double.maxFinite),
                  _buildSelectionMethodSelector(setDialogState),
                  _buildShuffled(setDialogState),
                  _buildInputProb(setDialogState),
                  _buildInputNum(setDialogState),
                  _buildRandomBrackets(setDialogState),
                  _buildTypeSelector(setDialogState),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(S.of(context).confirm))
                ],
              ),
            ));
  }

  void _showEditCommentDialog(Function setDialogState) {
    final controller = TextEditingController(text: widget.config.comment);
    setComment() {
      Navigator.of(context).pop();
      setState(() => widget.config.comment = controller.text);
      setDialogState(() {});
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(S.of(context).comment),
              content: TextField(
                controller: controller,
                autofocus: true,
                onSubmitted: (value) => setComment(),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(S.of(context).cancel)),
                TextButton(
                    onPressed: () => setComment(),
                    child: Text(S.of(context).confirm))
              ],
            ));
  }

  Widget _buildSelectionMethodSelector(Function setDialogState) {
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
      onSelectComplete: (value) {
        setState(() => widget.config.selectionMethod = value);
        setDialogState(() {});
      },
      leading: const Icon(Icons.select_all),
    );
  }

  _buildTypeSelector(Function setDialogState) {
    return SelectableListTile(
      title: S.of(context).cascaded_config_type,
      currentValue: widget.config.type,
      options: const ['str', 'config'],
      options_text: [
        S.of(context).cascaded_strings,
        S.of(context).cascaded_config_type_config
      ],
      onSelectComplete: (value) {
        setState(() => widget.config.type = value);
        setDialogState(() {});
      },
      leading: const Icon(Icons.type_specimen),
    );
  }

  Widget _buildInputProb(Function setDialogState) {
    return widget.config.selectionMethod == 'multiple_prob'
        ? EditableListTile(
            leading: const Icon(Icons.question_mark),
            title: S.of(context).selection_prob,
            currentValue: widget.config.prob.toString(),
            onEditComplete: (value) {
              setState(() {
                var n = double.tryParse(value);
                if (n != null && 0 <= n && n <= 1) {
                  widget.config.prob = n;
                }
              });
              setDialogState(() {});
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            confirmOnSubmit: true,
          )
        : const SizedBox.shrink();
  }

  Widget _buildInputNum(Function setDialogState) {
    return widget.config.selectionMethod == 'multiple_num'
        ? EditableListTile(
            leading: const Icon(Icons.question_mark),
            title: S.of(context).selection_num,
            currentValue: widget.config.num.toString(),
            onEditComplete: (value) {
              setState(() {
                var n = int.tryParse(value);
                if (n != null && 0 <= n) {
                  widget.config.num = n;
                }
              });
              setDialogState(() {});
            },
            keyboardType: TextInputType.number,
            confirmOnSubmit: true,
          )
        : const SizedBox.shrink();
  }

  Widget _buildShuffled(Function setDialogState) {
    return (widget.config.selectionMethod == 'all' ||
            widget.config.selectionMethod == 'multiple_prob')
        ? SwitchListTile(
            title: Text(S.of(context).shuffled),
            secondary: const Icon(Icons.shuffle),
            value: widget.config.shuffled,
            onChanged: (value) {
              setState(() => widget.config.shuffled = value);
              setDialogState(() {});
            })
        : const SizedBox.shrink();
  }

  Widget _buildRandomBrackets(Function setDialogState) {
    return Column(children: [
      ListTile(
        leading: const Icon(Icons.code),
        title: Text(
            '${S.of(context).random_brackets}: ${widget.config.randomBracketsLower.toString()} ~ ${widget.config.randomBracketsUpper.toString()}'),
        trailing: IconButton(
            onPressed: () {
              setState(() {
                widget.config.randomBracketsUpper = 0;
                widget.config.randomBracketsLower = 0;
              });
              setDialogState(() {});
            },
            icon: const Icon(Icons.refresh)),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 30),
          child: SizedBox(
              height: 20,
              child: RangeSlider(
                  values: RangeValues(
                      widget.config.randomBracketsLower.toDouble(),
                      widget.config.randomBracketsUpper.toDouble()),
                  labels: RangeLabels(
                      widget.config.randomBracketsLower.toInt().toString(),
                      widget.config.randomBracketsUpper.toInt().toString()),
                  min: -10,
                  max: 10,
                  divisions: 20,
                  onChanged: (range) {
                    setState(() {
                      widget.config.randomBracketsLower = range.start.round();
                      widget.config.randomBracketsUpper = range.end.round();
                    });
                    setDialogState(() {});
                  })))
    ]);
  }
}
