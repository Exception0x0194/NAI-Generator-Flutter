import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/generation_config_page/prompt_tab/character_config/character_config_view.dart';
import 'package:nai_casrand/ui/generation_config_page/prompt_tab/character_config/character_config_viewmodel.dart';
import 'package:nai_casrand/ui/generation_config_page/prompt_tab/prompt_tab_viewmodel.dart';
import 'package:nai_casrand/ui/generation_config_page/prompt_tab/prompt_config/prompt_config_view.dart';
import 'package:nai_casrand/ui/generation_config_page/prompt_tab/prompt_config/prompt_config_viewmodel.dart';

class PromptTabView extends StatelessWidget {
  const PromptTabView({super.key, required this.viewModel});

  final PromptTabViewmodel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
            PromptConfigView(
              viewModel: PromptConfigViewModel(
                config: viewModel.promptConfig,
              ),
            ),
            for (final (index, characterConfig)
                in viewModel.characterConfigList.indexed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('Character #$index')),
                    const Expanded(child: Divider())
                  ]),
                  CharacterConfigView(
                    viewModel: CharacterConfigViewmodel(
                      config: characterConfig,
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
