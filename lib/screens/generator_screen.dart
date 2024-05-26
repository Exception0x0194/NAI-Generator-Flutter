import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InfoManager().isRequesting
              ? const BlinkingIcon()
              : const Icon(Icons.cloud_upload, color: Colors.grey),
          title: const Text('Generation'),
        ),
        body: Center(
          child: _buildResponsiveLayout(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
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
                  onPressed: _toggleGeneration,
                  tooltip: 'Toggle generation',
                  child: InfoManager().isGenerating
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow))
            ],
          ),
        ));
  }

  Widget _buildResponsiveLayout() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
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
                  curve: Curves.ease,
                );
              }
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              itemCount: InfoManager().imgInfos.length,
              itemBuilder: (context, index) {
                return GenerationInfoWidget(
                    info: InfoManager().imgInfos[index]);
              },
            ),
          ),
        ));
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
}
