import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../models/info_manager.dart';
import '../models/utils.dart';
import '../widgets/generation_info_widget.dart';
import '../widgets/blinking_icon.dart';

class PromptGenerationScreen extends StatefulWidget {
  const PromptGenerationScreen({super.key});

  @override
  PromptGenerationScreenState createState() => PromptGenerationScreenState();
}

class PromptGenerationScreenState extends State<PromptGenerationScreen> {
  final ScrollController _scrollController = ScrollController();

  double _boxHeight = 1.0;

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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
              height: 40,
              child: Slider(
                min: 0.3,
                max: 1.0,
                value: _boxHeight,
                onChanged: (newHeight) {
                  setState(() {
                    _boxHeight = newHeight;
                  });
                },
                label: "Adjust image height",
              )),
          const SizedBox(width: 10),
          SpeedDial(
            icon: Icons.visibility,
            renderOverlay: false,
            closeManually: true,
            spaceBetweenChildren: 4,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.menu),
                label: 'Toggle show image with info',
                onTap: () => setState(() {
                  InfoManager().showInfoForImg = !InfoManager().showInfoForImg;
                }),
              ),
            ],
          ),
          const SizedBox(width: 20),
          SpeedDial(
            icon: Icons.construction,
            renderOverlay: false,
            closeManually: true,
            spaceBetweenChildren: 4,
            children: [
              SpeedDialChild(
                child: Icon(Icons.edit),
                label: 'Generate one prompt',
                onTap: _generatePrompt,
              ),
              SpeedDialChild(
                child: Icon(Icons.alarm),
                label: 'Set number of requests',
                onTap: _setRequestsNum,
              ),
            ],
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            tooltip: 'Toggle generation',
            onPressed: _toggleGeneration,
            shape: CircleBorder(),
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
    var columnItems = (1 / _boxHeight).floor();
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
                  height: _boxHeight * constraints.maxHeight,
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
      InfoManager().generateImage();
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
}
