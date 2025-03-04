import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/generation_page/widgets/info_card.dart';
import 'package:nai_casrand/ui/generation_page/view_models/generation_page_viewmodel.dart';
import 'package:nai_casrand/ui/core/widgets/slider_list_tile.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class GenerationPageView extends StatelessWidget {
  final GenerationPageViewmodel viewmodel;

  const GenerationPageView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: Listenable.merge([
        viewmodel.commandIdx,
        viewmodel.colNum,
      ]),
      builder: (context, child) {
        final itemCount = viewmodel.commandList.length;
        return WaterfallFlow.builder(
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: viewmodel.colNum.value),
          padding: EdgeInsets.all(8.0),
          itemCount: itemCount,
          itemBuilder: (context, index) => InfoCard(
            command: viewmodel.commandList[itemCount - 1 - index],
          ),
        );
      },
    );
    final buttons = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'gpfab1',
          onPressed: () => _showDisplaySettingsDialog(context),
          tooltip: tr('generation_settings'),
          child: const Icon(Icons.handyman_outlined),
        ),
        SizedBox(height: 20.0),
        FloatingActionButton(
          heroTag: 'gpfab2',
          onPressed: () => viewmodel.addTestPromptInfoCardContent(),
          tooltip: tr('generate_one_prompt'),
          child: const Icon(Icons.add),
        ),
        SizedBox(height: 20.0),
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
      listenable: viewmodel.colNum,
      builder: (context, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderListTile(
            title:
                '${tr('column_number')}: ${viewmodel.colNum.value.toString()}',
            sliderValue: viewmodel.colNum.value.toDouble(),
            min: 1.0,
            max: 5.0,
            divisions: 4,
            onChanged: (value) => viewmodel.setCardsPerCol(value.toInt()),
          ),
        ],
      ),
    );
  }
}
