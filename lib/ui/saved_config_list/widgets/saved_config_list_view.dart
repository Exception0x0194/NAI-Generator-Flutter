import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:nai_casrand/ui/prompt_config/view_models/prompt_config_viewmodel.dart';
import 'package:nai_casrand/ui/prompt_config/widgets/prompt_config_view.dart';
import 'package:nai_casrand/ui/saved_config_list/view_models/saved_config_list_viewmodel.dart';
import 'package:provider/provider.dart';

class SavedConfigListView extends StatelessWidget {
  final SavedConfigListViewmodel viewmodel;

  const SavedConfigListView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SavedConfigListViewmodel>.value(
      value: viewmodel,
      child: Consumer<SavedConfigListViewmodel>(
        builder: (context, value, child) => buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final pageTip = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: MarkdownBody(data: tr('saved_config_list_usage_tip')),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('saved_configs')),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            pageTip,
            ...viewmodel.configList.map((elem) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: PromptConfigView(
                            viewModel: PromptConfigViewModel(
                      config: elem,
                      isRoot: true,
                      initiallyExpanded: false,
                    ))),
                    IconButton(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        onPressed: () => viewmodel.removeConfig(elem),
                        icon: const Icon(Icons.delete_outline)),
                  ],
                )),
            Row(
              children: [
                const SizedBox(width: 20.0),
                Expanded(
                    child: ListTile(
                  title: Text(tr('saved_config_list_add')),
                  leading: const Icon(Icons.add),
                  onTap: () => viewmodel.addConfig(context),
                )),
                Expanded(
                    child: ListTile(
                  title: Text(tr('saved_config_list_import_from_clipborad')),
                  leading: const Icon(Icons.paste),
                  onTap: () => viewmodel.importConfigFromClipboard(context),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
