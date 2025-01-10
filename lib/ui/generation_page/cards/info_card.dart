import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nai_casrand/data/models/info_chip_content.dart';
import 'package:nai_casrand/ui/utils/flushbar.dart';

class InfoCard extends StatelessWidget {
  final InfoCardContent content;

  const InfoCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final cardBody = content.imageBytes == null
        ? //Widhout image
        SingleChildScrollView(
            child: ListTile(
            titleAlignment: ListTileTitleAlignment.top,
            leading: Icon(Icons.info_outline),
            title: Text(content.title),
            subtitle: Text(
              content.info,
              maxLines: null,
              softWrap: true,
            ),
          ))
        : // With image
        Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                titleAlignment: ListTileTitleAlignment.top,
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

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _showDetailedInfoDialog(context),
        child: ConstrainedBox(
            constraints: BoxConstraints.loose(Size(
              // Make bigger cards for images?
              content.imageBytes == null ? 500.0 : 500.0,
              double.maxFinite,
            )),
            child: cardBody),
      ),
    );
  }

  void _showDetailedInfoDialog(BuildContext context) {
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
}
