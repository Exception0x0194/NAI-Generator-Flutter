import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../generated/l10n.dart';

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

  const EditableListTile(
      {super.key,
      required this.title,
      required this.currentValue,
      required this.onEditComplete,
      this.keyboardType = TextInputType.text, // 默认为文本输入
      this.leading,
      this.dense,
      this.confirmOnSubmit,
      this.editValue,
      this.notice});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: Text(currentValue),
      onTap: () => _showEditDialog(context),
      dense: dense,
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: editValue ?? currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${context.tr('edit')}$title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              notice == null ? const SizedBox.shrink() : Text(notice!),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: null,
                onSubmitted: (confirmOnSubmit != null && confirmOnSubmit!)
                    ? (_) {
                        Navigator.of(context).pop();
                        onEditComplete(controller.text);
                      }
                    : null,
                autofocus: true,
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
  final List<String>? options_text; // 可能为空的额外文本选项
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
      this.options_text});

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
          title: Text('${context.tr('select')}$title'),
          children: List<Widget>.generate(options.length, (int index) {
            String displayText =
                options_text != null && options_text!.length > index
                    ? options_text![index]
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
