import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/settings_page/view_models/config_selection_page_viewmodel.dart';

class ConfigSelectionPageView extends StatelessWidget {
  final ConfigSelectionPageViewmodel viewmodel = ConfigSelectionPageViewmodel();
  final Function notificationCallback;

  ConfigSelectionPageView({super.key, required this.notificationCallback});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewmodel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(tr('saved_config'))),
        body: getBody(context),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    List<Widget> configListTiles = viewmodel.configIndexes.entries.map((item) {
      final uuid = item.key;
      final title = item.value;
      final buttons = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () => _showTitleEditDialog(context, uuid),
              icon: const Icon(Icons.edit)),
          const SizedBox(
            width: 8.0,
          ),
          IconButton(
              onPressed: () => viewmodel.saveConfigAsFile(context, uuid),
              icon: const Icon(Icons.file_download_outlined)),
          const SizedBox(
            width: 8.0,
          ),
          IconButton(
              onPressed: () => viewmodel.deleteConfig(context, uuid),
              icon: const Icon(Icons.delete_outline)),
        ],
      );
      return InkWell(
        child: ListTile(
          title: Text(title.toString()),
          trailing: buttons,
        ),
        onLongPress: () {
          viewmodel.loadSavedConfig(context, uuid);
          notificationCallback();
        },
      );
    }).toList();
    final currentConfigButton = ListTile(
      title: Text(tr('current_config')),
      trailing: IconButton(
        onPressed: () => viewmodel.saveCopyOfCurrentConfig(context),
        icon: const Icon(Icons.copy),
      ),
    );
    final importButton = ListTile(
      title: Text(tr('import_from_file')),
      trailing: IconButton(
        onPressed: () => viewmodel.importConfigFromFile(context),
        icon: const Icon(Icons.file_open_outlined),
      ),
      onTap: () => viewmodel.importConfigFromFile(context),
    );
    final pageHint = Text(tr('config_selection_page_hint'));
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            pageHint,
            currentConfigButton,
            const Divider(),
            ...configListTiles,
            if (configListTiles.isNotEmpty) const Divider(),
            importButton,
          ],
        ),
      ),
    );
  }

  void _showTitleEditDialog(BuildContext context, String uuid) {
    final controller = TextEditingController(
      text: viewmodel.configIndexes[uuid].toString(),
    );
    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: Text('${tr('edit')}${tr('colon')}${tr('title')}'),
              content: TextField(
                controller: controller,
                onSubmitted: (value) {
                  viewmodel.setConfigName(uuid, value);
                  Navigator.pop(dialogContext);
                },
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(tr('cancel'))),
                TextButton(
                  onPressed: () {
                    viewmodel.setConfigName(uuid, controller.text);
                    Navigator.pop(dialogContext);
                  },
                  child: Text(tr('confirm')),
                )
              ],
            ));
  }
}
