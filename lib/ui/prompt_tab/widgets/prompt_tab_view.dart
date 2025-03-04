import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/character_config/widgets/character_config_view.dart';
import 'package:nai_casrand/ui/character_config/view_models/character_config_viewmodel.dart';
import 'package:nai_casrand/ui/prompt_tab/view_models/prompt_tab_viewmodel.dart';
import 'package:nai_casrand/ui/prompt_config/widgets/prompt_config_view.dart';
import 'package:nai_casrand/ui/prompt_config/view_models/prompt_config_viewmodel.dart';
import 'package:nai_casrand/ui/saved_config_list/view_models/saved_config_list_viewmodel.dart';
import 'package:nai_casrand/ui/saved_config_list/widgets/saved_config_list_view.dart';
import 'package:provider/provider.dart';

class PromptTabView extends StatelessWidget {
  const PromptTabView({super.key, required this.viewmodel});

  final PromptTabViewmodel viewmodel;

  @override
  Widget build(BuildContext context) {
    final content = ChangeNotifierProvider.value(
      value: viewmodel,
      child: Consumer<PromptTabViewmodel>(
        builder: (context, value, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
                title: Text(context.tr('prompt_compact_view_hint')),
                dense: true),
            const Row(children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Base Prompts')),
              Expanded(child: Divider())
            ]),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: PromptConfigView(
                viewModel: PromptConfigViewModel(
                  config: viewmodel.promptConfig,
                ),
              ),
            ),
            for (final (index, characterConfig)
                in viewmodel.characterConfigList.indexed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('Character #$index')),
                    const Expanded(child: Divider())
                  ]),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: CharacterConfigView(
                      viewmodel: CharacterConfigViewmodel(
                        config: characterConfig,
                      ),
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
    final buttons = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SavedConfigListView(
                  viewmodel: SavedConfigListViewmodel(
                      configList: viewmodel.savedConfigList)))),
          tooltip: tr('manage_saved_configs'),
          heroTag: 'ptvfab1',
          child: const Icon(Icons.format_list_bulleted),
        ),
        SizedBox(height: 20.0),
        FloatingActionButton(
          onPressed: () => _showCharacterRearrangeDialog(context),
          tooltip: tr('rearrange_characters'),
          heroTag: 'ptvfab2',
          child: const Icon(Icons.group),
        ),
      ],
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: content,
      ),
      floatingActionButton: buttons,
    );
  }

  void _showCharacterRearrangeDialog(BuildContext context) {
    final addCharacterTile = ChangeNotifierProvider.value(
      value: viewmodel,
      child: Consumer<PromptTabViewmodel>(
          builder: (context, viewmodel, child) => ListTile(
                title: Text(tr('add_character')),
                leading: Icon(Icons.person_add),
                onTap: () => viewmodel.addCharacter(),
                enabled: viewmodel.characterConfigList.length < 5,
              )),
    );
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('${tr('edit')}${tr('colon')}${tr('characters')}'),
              content: SizedBox(
                  width: 400.0,
                  height: 600.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          child: CharacterRearrangeView(viewmodel: viewmodel)),
                      addCharacterTile,
                    ],
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(tr('confirm')))
              ],
            ));
  }
}

class CharacterRearrangeView extends StatelessWidget {
  final PromptTabViewmodel viewmodel;

  const CharacterRearrangeView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: viewmodel,
        child: Consumer<PromptTabViewmodel>(
          builder: (context, viewmodel, child) => ReorderableListView.builder(
            itemBuilder: (context, index) => ListTile(
              key: ValueKey(index),
              title: Text(
                  '#$index ${viewmodel.characterConfigList[index].positivePromptConfig.comment}'),
              leading: Icon(Icons.person),
              trailing: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    onPressed: () => viewmodel.removeCharacter(index),
                    icon: Icon(Icons.delete),
                  )),
            ),
            itemCount: viewmodel.characterConfigList.length,
            onReorder: (oldIndex, newIndex) =>
                viewmodel.reorderCharacter(oldIndex, newIndex),
          ),
        ));
  }
}
