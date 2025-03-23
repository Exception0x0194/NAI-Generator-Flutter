import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/prompt_config/widgets/prompt_config_delete_view.dart';
import 'package:nai_casrand/ui/prompt_config/widgets/prompt_config_edit_view.dart';
import 'package:nai_casrand/ui/prompt_config/widgets/prompt_config_reorder_view.dart';
import 'package:nai_casrand/ui/prompt_config/view_models/prompt_config_viewmodel.dart';
import 'package:provider/provider.dart';

class PromptConfigView extends StatelessWidget {
  final PromptConfigViewModel viewModel;

  const PromptConfigView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PromptConfigViewModel>.value(
      value: viewModel,
      child: Consumer<PromptConfigViewModel>(
        builder: (context, viewModel, child) {
          final backgroundColor = viewModel.isEnabled
              ? null
              : Theme.of(context).disabledColor.withAlpha(30);

          return Padding(
            padding: EdgeInsets.only(left: viewModel.isRoot ? 0 : 20),
            child: ExpansionTile(
              title: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  Text(viewModel.config.comment),
                  TextButton(
                    child: Text(viewModel.getConfigDescrption(context)),
                    onPressed: () => _showConfigDialog(viewModel, context),
                  )
                ]),
              ),
              trailing: viewModel.isRoot
                  ? const SizedBox.shrink()
                  : Switch(
                      value: viewModel.isEnabled,
                      onChanged: (value) => viewModel.setEnabled(value),
                    ),
              backgroundColor: backgroundColor,
              collapsedBackgroundColor: backgroundColor,
              controlAffinity: ListTileControlAffinity.leading,
              initiallyExpanded: viewModel.initiallyExpanded,
              children: _buildChildrenList(viewModel, context),
            ),
          );
        },
      ),
    );
  }

  void _showConfigDialog(
    PromptConfigViewModel viewModel,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => PromptConfigEditView(viewModel: viewModel),
    );
  }

  List<Widget> _buildChildrenList(
      PromptConfigViewModel viewModel, BuildContext context) {
    if (viewModel.config.type == 'config') {
      List<Widget> children = [];
      for (var subViewModel in viewModel.subConfigs) {
        children.add(PromptConfigView(viewModel: subViewModel));
      }
      children.add(_buildButtonsRow(viewModel, context));
      return children;
    } else {
      return [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ListTile(
            title: Text(
                '${context.tr('cascaded_strings')}${context.tr('colon')}${viewModel.config.strs.length}${context.tr('items')}'),
            subtitle: Text(viewModel.config.strs.join('\n')),
            onTap: () => _editStrList(context),
          ),
        )
      ];
    }
  }

  void _editStrList(BuildContext context) {
    TextEditingController controller =
        TextEditingController(text: viewModel.config.strs.join('\n'));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${context.tr('edit')}${context.tr('cascaded_strings')}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.tr('edit_cascaded_config_str_notice')),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // 允许无限行
                  autofocus: true,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(context.tr('cancel')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(context.tr('confirm')),
              onPressed: () {
                viewModel.setStrs(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtonsRow(
    PromptConfigViewModel viewModel,
    BuildContext context,
  ) {
    return ListTile(
        title: Row(
      children: [
        Expanded(
          child: Tooltip(
            message: context.tr('add_new_config'),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => viewModel.addNewConfig(),
            ),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: context.tr('import_config_from_clipboard'),
            child: IconButton(
              icon: const Icon(Icons.paste),
              onPressed: () => viewModel.importConfigFromClipboard(context),
            ),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: context.tr('reorder_config'),
            child: IconButton(
              icon: const Icon(Icons.cached),
              onPressed: () => _showReorderDialog(viewModel, context),
            ),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: context.tr('delete_config'),
            child: IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _showDeleteDialog(viewModel, context),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    ));
  }

  void _showReorderDialog(
    PromptConfigViewModel viewModel,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('reorder_config')),
          content: SizedBox(
            width: 400.0,
            height: 600.0,
            child: PromptConfigReorderView(viewModel: viewModel),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.tr('confirm')),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
    PromptConfigViewModel viewModel,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('delete_config')),
          content: SizedBox(
            width: 400.0,
            height: 600.0,
            child: PromptComfigDeleteView(viewModel: viewModel),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.tr('confirm')),
            ),
          ],
        );
      },
    );
  }
}
