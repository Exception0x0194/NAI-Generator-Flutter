import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/character_config/view_models/character_config_viewmodel.dart';
import 'package:nai_casrand/ui/prompt_config/widgets/prompt_config_view.dart';
import 'package:nai_casrand/ui/prompt_config/view_models/prompt_config_viewmodel.dart';
import 'package:nai_casrand/ui/core/widgets/editable_list_tile.dart';
import 'package:provider/provider.dart';

class CharacterConfigView extends StatelessWidget {
  final CharacterConfigViewmodel viewmodel;

  const CharacterConfigView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewmodel,
      child: Consumer<CharacterConfigViewmodel>(
        builder: (context, viewmodel, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: ListTile(
                    title: Text(tr('character_position')),
                    leading: const Icon(Icons.location_on),
                    subtitle: Text(viewmodel.getPositionsTexts()),
                    onTap: () => _showEditPositionDialog(context),
                  )),
                  Expanded(
                      child: EditableListTile(
                          title: tr('uc'),
                          leading: const Icon(Icons.do_not_disturb),
                          currentValue: viewmodel.config.negativePrompt,
                          maxLines: 1,
                          onEditComplete: (value) =>
                              viewmodel.setNegativePrompt(value)))
                ],
              ),
              PromptConfigView(
                  viewModel: PromptConfigViewModel(
                      config: viewmodel.config.positivePromptConfig)),
            ],
          );
        },
      ),
    );
  }

  void _showEditPositionDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                  '${tr('edit')}${tr('colon')}${tr('character_position')}'),
              content: CharacterPositionView(viewmodel: viewmodel),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(tr('confirm')))
              ],
            ));
  }
}

class CharacterPositionView extends StatelessWidget {
  final CharacterConfigViewmodel viewmodel;

  const CharacterPositionView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    const indexes = [1, 2, 3, 4, 5];
    const Map<int, String> xMapping = {
      1: 'A',
      2: 'B',
      3: 'C',
      4: 'D',
      5: 'E',
    };

    return ChangeNotifierProvider.value(
        value: viewmodel,
        builder: (context, child) => Consumer<CharacterConfigViewmodel>(
              builder: (context, viewmodel, child) {
                List<Widget> rows = [];
                for (final y in indexes) {
                  List<Widget> cols = [];
                  for (final x in indexes) {
                    final pt = Point(x, y);
                    final selected = viewmodel.config.positions.contains(pt);
                    cols.add(InkWell(
                      child: SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: selected
                                  ? Colors.transparent
                                  : Colors.grey.withOpacity(0.3)),
                          child: Center(
                              child: Text('${xMapping[x]}${y.toString()}')),
                        ),
                      ),
                      onTap: () => viewmodel.switchPosition(pt),
                    ));
                  }
                  rows.add(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: cols,
                  ));
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: rows,
                );
              },
            ));
  }
}
