import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nai_casrand/data/models/info_card_content.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:flutter_command/flutter_command.dart';

class InfoCard extends StatelessWidget {
  final Command<void, InfoCardContent> command;

  const InfoCard({super.key, required this.command});

  @override
  Widget build(BuildContext context) {
    final cardBody = ListenableBuilder(
      listenable: command.isExecuting,
      builder: (context, child) {
        if (command.isExecuting.value) {
          // Loading
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Requesting...'),
          );
        } else {
          // Result
          return _buildCardContentBody(context, command.value);
        }
      },
    );

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _showDetailedInfoDialog(context),
        child: cardBody,
      ),
    );
  }

  void _showDetailedInfoDialog(BuildContext context) {
    if (command.isExecuting.value) return;
    final content = command.value;

    // 跳转到新页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoDetailPage(content: content),
      ),
    );
  }

  Widget buildInfoTile(String title, String content, BuildContext context) {
    return ListTile(
      titleAlignment: ListTileTitleAlignment.titleHeight,
      title: Text(title),
      subtitle: Text(content),
      trailing: IconButton(
          onPressed: () {
            _copyContent(content, context);
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.copy)),
    );
  }

  void _copyContent(String content, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    showInfoBar(context, '${tr('info_export_to_clipboard')}${tr('succeed')}');
  }

  Widget _buildCardContentBody(BuildContext context, InfoCardContent content) {
    return content.imageBytes == null
        ? //Without image
        Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(content.title),
              ),
              ListTile(
                subtitle: Text(
                  content.info,
                  maxLines: 20,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          )
        : // With image
        Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_outlined),
                title: Text(
                  content.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Image.memory(
                fit: BoxFit.contain,
                content.imageBytes!,
                filterQuality: FilterQuality.medium,
              ),
            ],
          );
  }
}

class InfoDetailPage extends StatelessWidget {
  final InfoCardContent content;

  const InfoDetailPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    List<Widget> contents = [
      buildInfoTile(tr('title'), content.title, context),
      buildInfoTile(tr('info'), content.info, context),
    ];
    for (final item in content.additionalInfo.entries) {
      contents.add(buildInfoTile(item.key, item.value.toString(), context));
    }

    final body = Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (content.imageBytes != null)
              Image.memory(content.imageBytes!, fit: BoxFit.contain),
            ...contents,
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: body,
    );
  }

  Widget buildInfoTile(String title, String content, BuildContext context) {
    return Column(children: [
      ListTile(
          titleAlignment: ListTileTitleAlignment.top,
          title: Text(title),
          subtitle: Text(content),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            getSelectableTextPage(title, content)));
                  },
                  icon: Icon(
                    Icons.visibility_outlined,
                  )),
              SizedBox(width: 16.0),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyContent(content, context);
                  },
                  tooltip: tr('copy_to_clipboard'),
                  icon: Icon(Icons.copy)),
            ],
          )),
      Divider(),
    ]);
  }

  void _copyContent(String content, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    showInfoBar(context, '${tr('info_export_to_clipboard')}${tr('succeed')}');
  }

  getSelectableTextPage(String title, String text) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('selectable') + tr('colon') + title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SelectableText(text),
      ),
    );
  }
}
