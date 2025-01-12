import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nai_casrand/data/models/info_card_content.dart';
import 'package:nai_casrand/ui/utils/flushbar.dart';
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
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(
            const Size(
              500.0,
              double.maxFinite,
            ),
          ),
          child: cardBody,
        ),
      ),
    );
  }

  void _showDetailedInfoDialog(BuildContext context) {
    if (command.isExecuting.value) return;
    final content = command.value;
    List<Widget> contents = [
      buildInfoTile(
        'Title',
        content.title,
        context,
      ),
      buildInfoTile(
        'Info',
        content.info,
        context,
      )
    ];
    for (final item in content.additionalInfo.entries) {
      contents.add(buildInfoTile(
        item.key,
        item.value.toString(),
        context,
      ));
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                content.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              content: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: contents,
              )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(tr('confirm')))
              ],
            ));
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
        SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(content.title),
              ),
              ListTile(
                subtitle: Text(content.info, softWrap: true),
              )
            ],
          ))
        : // With image
        Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_outlined),
                title: Text(content.title),
              ),
              Expanded(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(
                        fit: BoxFit.contain,
                        content.imageBytes!,
                        filterQuality: FilterQuality.medium,
                      ))),
            ],
          );
  }
}
