import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
        title: const Text('Generation'),
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
            tooltip: 'Generation settings',
            onPressed: _showGenerationSettingsDialog,
            child: const Icon(Icons.construction),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            tooltip: 'Toggle generation',
            onPressed: _toggleGeneration,
            child: Icon(
                InfoManager().isGenerating ? Icons.stop : Icons.play_arrow),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationInfoList() {
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
              child: ListView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                children: _buildColumns(),
              ),
            ),
          );
        }));
  }

  List<Widget> _buildColumns() {
    var columnItems = (1 / GlobalSettings().infoHeight).floor();
    List<Widget> columns = [];
    List<dynamic> infos = InfoManager().generationInfos;
    for (int i = 0; i < infos.length; i += columnItems) {
      int end =
          (i + columnItems > infos.length) ? infos.length : i + columnItems;
      var col = LayoutBuilder(builder: ((context, constraints) {
        List<Widget> columnChildren = [];
        for (int j = i; j < end; j++) {
          columnChildren.add(Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                  height: GlobalSettings().infoHeight * constraints.maxHeight,
                  child: GenerationInfoWidget(info: infos[j]))));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: columnChildren,
        );
      }));
      columns.add(col);
    }
    return columns;
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

  void _setRequestsNum() {
    final controller =
        TextEditingController(text: InfoManager().remainingRequests.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Number of Requests - 0 for looping'),
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
                    showInfoBar(context, 'Set looping generation.');
                  } else {
                    showInfoBar(context, 'Set $n requests.');
                  }
                } else {
                  showErrorBar(context, 'Error setting number of requests!');
                }
              },
              child: const Text('Set'),
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
              title: const Text('Generation Settings'),
              children: [
                ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('Info tile height'),
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
                  title: const Text('Toggle info display aside images'),
                  value: GlobalSettings().showInfoForImg,
                  onChanged: (value) {
                    setState(() => GlobalSettings().showInfoForImg = value);
                    setDialogState(() {});
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.shuffle),
                  title: const Text('Use random seed'),
                  subtitle: Text(InfoManager().paramConfig.randomSeed
                      ? 'Enabled'
                      : 'Disabled'),
                  value: InfoManager().paramConfig.randomSeed,
                  onChanged: (value) {
                    setDialogState(
                        () => InfoManager().paramConfig.randomSeed = value);
                    setDialogState(() {});
                  },
                ),
                if (!InfoManager().paramConfig.randomSeed)
                  Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: EditableListTile(
                          title: 'Seed',
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
                  title: const Text('Image numbers to generate'),
                  subtitle: Text(InfoManager().remainingRequests == 0
                      ? '∞'
                      : InfoManager().remainingRequests.toString()),
                  onTap: () {
                    _setRequestsNum();
                    setDialogState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Generate one prompt'),
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
