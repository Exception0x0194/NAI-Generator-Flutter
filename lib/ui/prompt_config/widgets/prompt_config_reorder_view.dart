import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/prompt_config/view_models/prompt_config_viewmodel.dart';
import 'package:provider/provider.dart';

class PromptConfigReorderView extends StatelessWidget {
  final PromptConfigViewModel viewModel;

  const PromptConfigReorderView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: viewModel,
        child: Consumer<PromptConfigViewModel>(
            builder: (context, viewModel, child) {
          return ReorderableListView.builder(
              itemBuilder: (context, index) {
                final prompt = viewModel.config.prompts[index];
                return ListTile(
                    key: ValueKey(index), title: Text(prompt.comment));
              },
              itemCount: viewModel.config.prompts.length,
              onReorder: (oldIndex, newIndex) =>
                  viewModel.reorder(oldIndex, newIndex));
        }));
  }
}
