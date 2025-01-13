import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/prompt_config/view_models/prompt_config_viewmodel.dart';
import 'package:provider/provider.dart';

class PromptComfigDeleteView extends StatelessWidget {
  final PromptConfigViewModel viewModel;

  const PromptComfigDeleteView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<PromptConfigViewModel>(
        builder: (context, viewModel, child) {
          return ListView.builder(
            itemCount: viewModel.config.prompts.length,
            itemBuilder: (context, index) {
              final prompt = viewModel.config.prompts[index];
              return ListTile(
                title: Text(prompt.comment),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    viewModel.removeConfigAt(index);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
