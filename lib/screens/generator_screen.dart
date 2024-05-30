import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/global_settings.dart';
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
    var itemsPerCol = (1 / GlobalSettings().infoHeight).floor();
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
                return _buildColumn(index);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildColumn(int index) {
    var columnItems = (1 / GlobalSettings().infoHeight).floor();
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
            height: GlobalSettings().infoHeight * constraints.maxHeight,
            child: GenerationInfoWidget(info: InfoManager().generationInfos[j]),
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
    }
  }

  void _setRequestsNum(Function onComplete) {
    final controller =
        TextEditingController(text: InfoManager().remainingRequests.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).edit_image_number_to_generate),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLines: null,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                var ok = _onSetRequestsComplete(controller.text);
                Navigator.of(context).pop();
                if (ok) {
                  var n = InfoManager().remainingRequests;
                  if (n == 0) {
                    showInfoBar(
                        context, S.of(context).info_set_looping_genration);
                  } else {
                    showInfoBar(
                        context, S.of(context).info_set_genration_number(n));
                  }
                } else {
                  showErrorBar(
                      context, S.of(context).info_set_genration_number_failed);
                }
                onComplete();
              },
              child: Text(S.of(context).confirm),
            ),
          ],
        );
      },
    );
  }

  bool _onSetRequestsComplete(String text) {
    var parseResult = int.tryParse(text);
    if (parseResult == null) {
      return false;
    }
    setState(() {
      InfoManager().remainingRequests = parseResult;
    });
    return true;
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
                      label: GlobalSettings().infoHeight.toStringAsFixed(1),
                      value: GlobalSettings().infoHeight,
                      onChanged: (newHeight) {
                        setState(() {
                          GlobalSettings().infoHeight = newHeight;
                        });
                        setDialogState(() {});
                      },
                    )),
                SwitchListTile(
                  secondary: GlobalSettings().showInfoForImg
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.visibility),
                  title: Text(S.of(context).toggle_display_info_aside_img),
                  value: GlobalSettings().showInfoForImg,
                  onChanged: (value) {
                    setState(() => GlobalSettings().showInfoForImg = value);
                    setDialogState(() {});
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.shuffle),
                  title: Text(S.of(context).use_random_seed),
                  value: InfoManager().paramConfig.randomSeed,
                  onChanged: (value) {
                    setState(
                        () => InfoManager().paramConfig.randomSeed = value);
                    setDialogState(() {});
                  },
                ),
                if (!InfoManager().paramConfig.randomSeed)
                  Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: EditableListTile(
                          title: S.of(context).random_seed,
                          currentValue:
                              InfoManager().paramConfig.seed.toString(),
                          onEditComplete: (value) => {
                                setDialogState(() {
                                  InfoManager().paramConfig.seed =
                                      int.tryParse(value) ??
                                          InfoManager().paramConfig.seed;
                                })
                              })),
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: Text(S.of(context).image_number_to_generate),
                  subtitle: Text(InfoManager().remainingRequests == 0
                      ? '∞'
                      : InfoManager().remainingRequests.toString()),
                  onTap: () {
                    _setRequestsNum(() {
                      setDialogState(() {});
                    });
                  },
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
}
