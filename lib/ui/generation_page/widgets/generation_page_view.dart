import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/core/widgets/editable_list_tile.dart';
import 'package:nai_casrand/ui/generation_page/widgets/info_card.dart';
import 'package:nai_casrand/ui/generation_page/view_models/generation_page_viewmodel.dart';
import 'package:nai_casrand/ui/core/widgets/slider_list_tile.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class GenerationPageView extends StatelessWidget {
  final GenerationPageViewmodel viewmodel;

  const GenerationPageView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final content = ListenableBuilder(
        listenable: viewmodel,
        builder: (context, _) {
          final itemCount = viewmodel.commandList.length;
          return Column(
            children: [
              Expanded(
                child: WaterfallFlow.builder(
                  gridDelegate:
                      SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                          crossAxisCount: viewmodel.colNum),
                  padding: const EdgeInsets.all(8.0),
                  itemCount: itemCount,
                  itemBuilder: (context, index) => InfoCard(
                    command: viewmodel.commandList[itemCount - 1 - index],
                  ),
                ),
              ),
              if (viewmodel.payloadConfig.useOverridePrompt)
                EditableListTile(
                  title: tr('override_prompt'),
                  leading: const Icon(Icons.edit_note),
                  maxLines: 2,
                  keyboardType: TextInputType.multiline,
                  currentValue: viewmodel.payloadConfig.overridePrompt,
                  onEditComplete: (value) => viewmodel.setOverridePrompt(value),
                  confirmOnSubmit: true,
                ),
              if (viewmodel.payloadConfig.useOverridePrompt)
                EditableListTile(
                  title: tr('uc'),
                  leading: const Icon(Icons.do_not_disturb),
                  maxLines: 1,
                  keyboardType: TextInputType.multiline,
                  currentValue:
                      viewmodel.payloadConfig.paramConfig.negativePrompt,
                  onEditComplete: (value) => viewmodel.setUC(value),
                  confirmOnSubmit: true,
                )
            ],
          );
        });
    final buttons = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'gpfab1',
          onPressed: () => _showDisplaySettingsDialog(context),
          tooltip: tr('generation_settings'),
          child: const Icon(Icons.handyman_outlined),
        ),
        const SizedBox(height: 20.0),
        FloatingActionButton(
          heroTag: 'gpfab2',
          onPressed: () => viewmodel.addTestPromptInfoCardContent(),
          tooltip: tr('generate_one_prompt'),
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 20.0),
        FloatingActionButton(
          heroTag: 'gpfab3',
          onPressed: () => viewmodel.toggleBatch(),
          tooltip: tr('toggle_generation'),
          child: ListenableBuilder(
            listenable: viewmodel.commandStatus.isBatchActive,
            builder: (context, child) => Icon(
                viewmodel.commandStatus.isBatchActive.value
                    ? Icons.stop
                    : Icons.play_arrow),
          ),
        ),
      ],
    );
    return Scaffold(
      body: content,
      floatingActionButton: buttons,
    );
  }

  void _showDisplaySettingsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(tr('generation_settings')),
              content: DisplaySettingsView(viewmodel: viewmodel),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(tr('confirm')))
              ],
            ));
  }
}

class DisplaySettingsView extends StatelessWidget {
  final GenerationPageViewmodel viewmodel;

  const DisplaySettingsView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: viewmodel,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderListTile(
                title: '${tr('column_number')}: ${viewmodel.colNum.toString()}',
                sliderValue: viewmodel.colNum.toDouble(),
                min: 1.0,
                max: 5.0,
                divisions: 4,
                onChanged: (value) => viewmodel.setCardsPerCol(value.toInt()),
              ),
              ListTile(
                title: Text(tr('clear_list')),
                leading: const Icon(Icons.clear_all),
                onTap: viewmodel.clearCommandList,
              ),
              CheckboxListTile(
                title: Text(tr('override_random_prompts')),
                secondary: const Icon(Icons.edit),
                value: viewmodel.payloadConfig.useOverridePrompt,
                onChanged: (value) => viewmodel.setOverride(value),
              ),
              if (viewmodel.payloadConfig.useOverridePrompt)
                CheckboxListTile(
                  title: Text(tr('use_character_prompt')),
                  secondary: const Icon(Icons.edit),
                  value: viewmodel.payloadConfig.useCharacterPromptWithOverride,
                  onChanged: (value) => viewmodel.setCharacterOverride(value),
                ),
            ],
          );
        });
  }
}
