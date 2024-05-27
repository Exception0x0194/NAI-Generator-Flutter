import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/models/utils.dart';
import 'package:nai_casrand/widgets/generation_info_widget.dart';

import '../models/info_manager.dart';

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
        Slider(
          min: 0.5,
          max: 1.0,
          value: _boxHeight,
          onChanged: (newHeight) {
            setState(() {
              _boxHeight = newHeight;
            });
          },
          label: "Adjust image height",
        ),
        Expanded(
            child: Align(
          alignment: Alignment.bottomCenter,
          child: _buildResponsiveLayout(),
        ))
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              onPressed: _generatePrompt,
              tooltip: 'Generate one prompt',
              child: const Icon(Icons.edit)),
          const SizedBox(
            height: 20,
          ),
          FloatingActionButton(
              onPressed: _setRequestsNum,
              tooltip: 'Set number of requests',
              child: const Icon(Icons.alarm)),
          const SizedBox(
            height: 20,
          ),
          FloatingActionButton(
              onPressed: _toggleGeneration,
              tooltip: 'Toggle generation',
              child: InfoManager().isGenerating
                  ? const Icon(Icons.stop)
                  : const Icon(Icons.play_arrow))
        ],
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
              height: _boxHeight * constraints.maxHeight,
              child: Scrollbar(
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
                    itemCount: InfoManager().generationInfos.length,
                    itemBuilder: (context, index) {
                      return GenerationInfoWidget(
                          info: InfoManager().generationInfos[index]);
                    },
                  ),
                ),
              ));
        }));
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
