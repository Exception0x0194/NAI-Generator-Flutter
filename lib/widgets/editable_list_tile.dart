import 'package:flutter/material.dart';

class EditableListTile extends StatelessWidget {
  final String title;
  final String currentValue;
  final Function(String) onEditComplete;
  final TextInputType keyboardType;
  final Icon? leading;

  const EditableListTile({
    super.key,
    required this.title,
    required this.currentValue,
    required this.onEditComplete,
    this.keyboardType = TextInputType.text, // 默认为文本输入
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: Text(currentValue),
      onTap: () => _showEditDialog(context),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: null,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onEditComplete(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
