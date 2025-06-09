import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class EditableListTile extends StatelessWidget {
  final String title;
  final String currentValue;
  final Function(String) onEditComplete;
  final TextInputType keyboardType;
  final Icon? leading;
  final bool? dense;
  final bool? confirmOnSubmit;
  final String? editValue;
  final String? notice;
  final int? maxLines;

  const EditableListTile({
    super.key,
    required this.title,
    required this.currentValue,
    required this.onEditComplete,
    this.keyboardType = TextInputType.text, // 默认为文本输入
    this.leading,
    this.dense,
    this.confirmOnSubmit,
    this.editValue,
    this.notice,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: Text(
        currentValue,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _showEditDialog(context),
      dense: dense,
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: editValue ?? currentValue);
    showDialog(
      context: context,
      builder: (context) {
        submitText() {
          Navigator.of(context).pop();
          onEditComplete(controller.text);
        }

        final focusNode = FocusNode(onKeyEvent: (node, event) {
          if (event.logicalKey.keyLabel == 'Enter' && event is KeyDownEvent) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              // Shift + Enter
              return KeyEventResult.ignored;
            }
            // Enter
            if (confirmOnSubmit ?? false == true) {
              submitText();
            }
            KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        });

        return AlertDialog(
          title: Text('${context.tr('edit')}${context.tr('colon')}$title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              notice == null ? const SizedBox.shrink() : GptMarkdown(notice!),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: null,
                autofocus: true,
                focusNode: focusNode,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onEditComplete(controller.text);
              },
              child: Text(context.tr('confirm')),
            ),
          ],
        );
      },
    );
  }
}

class SelectableListTile extends StatelessWidget {
  final String title;
  final String currentValue;
  final List<String> options;
  final List<String>? optionsText; // 可能为空的额外文本选项
  final Function(String) onSelectComplete;
  final Icon? leading;
  final bool? dense;

  const SelectableListTile(
      {required this.title,
      required this.currentValue,
      required this.options,
      required this.onSelectComplete,
      super.key,
      this.leading,
      this.dense,
      this.optionsText});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: Text(currentValue),
      onTap: () => _showSelectDialog(context),
      dense: dense,
    );
  }

  void _showSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('${context.tr('select')}${context.tr('colon')}$title'),
          children: List<Widget>.generate(options.length, (int index) {
            String displayText =
                optionsText != null && optionsText!.length > index
                    ? optionsText![index]
                    : options[index];
            return SimpleDialogOption(
              onPressed: () {
                onSelectComplete(options[index]);
                Navigator.pop(context);
              },
              child: ListTile(
                title: Text(
                  displayText,
                  style: TextStyle(
                      fontWeight: currentValue == options[index]
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
