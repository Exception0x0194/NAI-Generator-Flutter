import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/info_manager.dart';
import '../models/utils.dart';
import '../widgets/editable_list_tile.dart';
import '../widgets/generation_info_widget.dart';
import '../widgets/blinking_icon.dart';

class PromptGenerationScreen extends StatefulWidget {
  const PromptGenerationScreen({super.key});

  @override
  PromptGenerationScreenState createState() => PromptGenerationScreenState();
}

class PromptGenerationScreenState extends State<PromptGenerationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InfoManager().isRequesting
            ? const BlinkingIcon()
            : const Icon(Icons.cloud_upload, color: Colors.grey),
        title: Text(S.of(context).generation),
      ),
      body: Column(children: [
        Expanded(
            child: Align(
          alignment: Alignment.bottomCenter,
          child: _buildGenerationInfoList(),
        ))
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: S.of(context).generation_settings,
            onPressed: _showGenerationSettingsDialog,
            child: const Icon(Icons.construction),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            tooltip: S.of(context).toggle_generation,
            onPressed: _toggleGeneration,
            child: Icon(
                InfoManager().isGenerating ? Icons.stop : Icons.play_arrow),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationInfoList() {
    var itemsPerCol = (1 / InfoManager().infoTileHeight).floor();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: LayoutBuilder(builder: (context, constraints) {
        return Scrollbar(
          controller: _scrollController,
          thickness: 20,
          radius: const Radius.circular(10),
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                _scrollController.animateTo(
                  _scrollController.offset + pointerSignal.scrollDelta.dy,
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.linear,
                );
              }
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              itemCount:
                  (InfoManager().generationInfos.length / itemsPerCol).ceil(),
              itemBuilder: (context, index) {
                return _buildGenerationInfoColumn(index);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGenerationInfoColumn(int index) {
    var columnItems = (1 / InfoManager().infoTileHeight).floor();
    int startIndex = index * columnItems;
    int endIndex = startIndex + columnItems;
    if (endIndex > InfoManager().generationInfos.length) {
      endIndex = InfoManager().generationInfos.length;
    }

    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> columnChildren = [];
      for (int j = startIndex; j < endIndex; j++) {
        columnChildren.add(Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            height: InfoManager().infoTileHeight * constraints.maxHeight,
            child: GenerationInfoWidget(
                info: InfoManager().generationInfos[j],
                showInfoForImg: InfoManager().showInfoForImg),
          ),
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: columnChildren,
      );
    });
  }

  void _generatePrompt() async {
    InfoManager().generatePrompt();
  }

  void _toggleGeneration() async {
    setState(() {
      InfoManager().isGenerating = !InfoManager().isGenerating;
    });
    if (InfoManager().isGenerating) {
      InfoManager().startGeneration();
      var n = InfoManager().presetRequests;
      showInfoBar(context,
          S.of(context).info_start_generation(n == 0 ? '∞' : n.toString()));
    }
  }

  void _showGenerationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return SimpleDialog(
              title: Text(S.of(context).generation_settings),
              children: [
                ListTile(
                    leading: const Icon(Icons.search),
                    title: Text(S.of(context).info_tile_height),
                    subtitle: Slider(
                      min: 0.3,
                      max: 1.0,
                      divisions: 7,
                      label: InfoManager().infoTileHeight.toStringAsFixed(1),
                      value: InfoManager().infoTileHeight,
                      onChanged: (newHeight) {
                        setState(() {
                          InfoManager().infoTileHeight = newHeight;
                        });
                        setDialogState(() {});
                      },
                    )),
                SwitchListTile(
                  secondary: InfoManager().showInfoForImg
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.visibility),
                  title: Text(S.of(context).toggle_display_info_aside_img),
                  value: InfoManager().showInfoForImg,
                  onChanged: (value) {
                    setState(() => InfoManager().showInfoForImg = value);
                    setDialogState(() {});
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.shuffle),
                  title: Text(S.of(context).use_random_seed),
                  value: InfoManager().paramConfig.randomSeed,
                  onChanged: (value) {
                    setDialogState(() {
                      InfoManager().paramConfig.randomSeed = value;
                    });
                  },
                ),
                if (!InfoManager().paramConfig.randomSeed)
                  Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: EditableListTile(
                          title: S.of(context).random_seed,
                          currentValue:
                              InfoManager().paramConfig.seed.toString(),
                          confirmOnSubmit: true,
                          onEditComplete: (value) => {
                                setDialogState(() {
                                  InfoManager().paramConfig.seed =
                                      int.tryParse(value) ??
                                          InfoManager().paramConfig.seed;
                                })
                              })),
                EditableListTile(
                  leading: const Icon(Icons.alarm),
                  title: S.of(context).image_number_to_generate,
                  currentValue: InfoManager().presetRequests == 0
                      ? '∞'
                      : InfoManager().presetRequests.toString(),
                  editValue: InfoManager().presetRequests.toString(),
                  notice: '0 → ∞',
                  onEditComplete: (value) {
                    _setPresetRequestNum(value);
                    setDialogState(() {});
                  },
                  keyboardType: TextInputType.number,
                  confirmOnSubmit: true,
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(S.of(context).generate_one_prompt),
                  onTap: _generatePrompt,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _setPresetRequestNum(value) {
    var parseResult = int.tryParse(value);
    if (parseResult == null || parseResult < 0) {
      showErrorBar(context, S.of(context).info_set_genration_number_failed);
      return;
    }
    InfoManager().presetRequests = parseResult;
    showInfoBar(
        context,
        S.of(context).info_set_genration_number(
            parseResult == 0 ? '∞' : parseResult.toString()));
  }
}
