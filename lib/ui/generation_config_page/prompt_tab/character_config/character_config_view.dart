import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/generation_config_page/prompt_tab/character_config/character_config_viewmodel.dart';
import 'package:nai_casrand/ui/generation_config_page/prompt_tab/prompt_config/prompt_config_view.dart';
import 'package:nai_casrand/ui/generation_config_page/prompt_tab/prompt_config/prompt_config_viewmodel.dart';
import 'package:nai_casrand/widgets/editable_list_tile.dart';
import 'package:provider/provider.dart';

class CharacterConfigView extends StatelessWidget {
  final CharacterConfigViewmodel viewModel;

  const CharacterConfigView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CharacterConfigViewmodel>(
        builder: (context, viewModel, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: ListTile(
                    title: Text('Position'),
                    subtitle: Text(viewModel.getPositionsTexts()),
                    onTap: _showEditPositionDialog,
                  )),
                  Expanded(
                      child: EditableListTile(
                          title: 'Negative Prompts',
                          currentValue: viewModel.config.negativePrompt,
                          onEditComplete: (value) =>
                              viewModel.setNegativePrompt(value)))
                ],
              ),
              PromptConfigView(
                  viewModel: PromptConfigViewModel(
                      config: viewModel.config.positivePromptConfig)),
            ],
          );
        },
      ),
    );
  }

  void _showEditPositionDialog() {}
}
