import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/prompt_config/view_models/prompt_config_viewmodel.dart';
import 'package:nai_casrand/ui/core/widgets/editable_list_tile.dart';
import 'package:nai_casrand/ui/core/widgets/slider_list_tile.dart';

class PromptConfigEditView extends StatelessWidget {
  final PromptConfigViewModel viewModel;

  const PromptConfigEditView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final title = InkWell(
      child: Text(viewModel.config.comment),
      onTap: () => _showEditCommentDialog(context),
    );
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => AlertDialog(
        title: title,
        content: _buildBody(context),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.copyToClipboard(context);
              Navigator.of(context).pop();
            },
            child: Text(tr('copy_to_clipboard')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('confirm')),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildToolTip(context),
        _buildSelectionMethodTile(viewModel, context),
        _buildShuffledTile(viewModel, context),
        _buildNumTile(viewModel, context),
        _buildProbTile(viewModel, context),
        _buildRandomBrackets(viewModel, context),
        _buildTypeTile(viewModel, context),
      ],
    );
  }

  Widget _buildSelectionMethodTile(
      PromptConfigViewModel viewModel, BuildContext context) {
    return SelectableListTile(
      title: context.tr('selection_method'),
      currentValue: viewModel.config.selectionMethod,
      options: const [
        'all',
        'single',
        'single_sequential',
        'multiple_prob',
        'multiple_num'
      ],
      optionsText: [
        context.tr('selection_method_all'),
        context.tr('selection_method_single'),
        context.tr('selection_method_single_sequential'),
        context.tr('selection_method_multiple_prob'),
        context.tr('selection_method_multiple_num')
      ],
      onSelectComplete: (value) => viewModel.setSelectionMethod(value),
      leading: const Icon(Icons.select_all),
    );
  }

  Widget _buildShuffledTile(
      PromptConfigViewModel viewModel, BuildContext context) {
    if (viewModel.config.selectionMethod != 'all' &&
        viewModel.config.selectionMethod != 'multiple_prob') {
      return const SizedBox.shrink();
    }
    return CheckboxListTile(
      title: Text(context.tr('shuffled')),
      value: viewModel.config.shuffled,
      onChanged: (value) {
        if (value == null) return;
        viewModel.setShuffled(value);
      },
      secondary: const Icon(Icons.shuffle),
    );
  }

  Widget _buildProbTile(PromptConfigViewModel viewModel, BuildContext context) {
    if (viewModel.config.selectionMethod != 'multiple_prob') {
      return const SizedBox.shrink();
    }
    return SliderListTile(
      title:
          '${context.tr('selection_prob')}${context.tr('colon')}${viewModel.config.prob}',
      sliderValue: viewModel.config.prob,
      min: 0.0,
      max: 1.0,
      divisions: 100,
      leading: const Icon(Icons.question_mark),
      onChanged: (value) => viewModel.setProb(value),
    );
  }

  Widget _buildTypeTile(PromptConfigViewModel viewModel, BuildContext context) {
    return SelectableListTile(
      title: context.tr('cascaded_config_type'),
      currentValue: viewModel.config.type,
      options: const ['str', 'config'],
      optionsText: [
        context.tr('cascaded_strings'),
        context.tr('cascaded_config_type_config')
      ],
      onSelectComplete: (value) => viewModel.setType(value),
      leading: const Icon(Icons.type_specimen),
    );
  }

  Widget _buildRandomBrackets(
      PromptConfigViewModel viewModel, BuildContext context) {
    return RangeListTile(
      title:
          '${context.tr('random_brackets')}${context.tr('colon')}${viewModel.config.randomBracketsLower.toString()} ~ ${viewModel.config.randomBracketsUpper.toString()}',
      sliderStart: viewModel.config.randomBracketsLower.toDouble(),
      sliderEnd: viewModel.config.randomBracketsUpper.toDouble(),
      min: -10.0,
      max: 10.0,
      divisions: 20,
      leading: const Icon(Icons.code),
      onChanged: (lower, upper) =>
          viewModel.setRandomBrackets(lower.toInt(), upper.toInt()),
    );
  }

  Widget _buildNumTile(PromptConfigViewModel viewModel, BuildContext context) {
    if (viewModel.config.selectionMethod != 'multiple_num') {
      return const SizedBox.shrink();
    }
    return EditableListTile(
        title: tr('selection_num'),
        leading: const Icon(Icons.question_mark),
        confirmOnSubmit: true,
        keyboardType: TextInputType.number,
        currentValue: viewModel.config.num.toString(),
        onEditComplete: (value) =>
            viewModel.setNum(int.tryParse(value) ?? viewModel.config.num));
  }

  Widget _buildToolTip(BuildContext context) {
    return Text(tr('prompt_edit_tooltip'));
  }

  _showEditCommentDialog(BuildContext context) {
    final controller = TextEditingController(text: viewModel.config.comment);
    setComment() {
      viewModel.setComment(controller.text);
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('comment')),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (value) => setComment(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('cancel'))),
          TextButton(
              onPressed: () => setComment(), child: Text(context.tr('confirm')))
        ],
      ),
    );
  }
}
