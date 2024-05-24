import 'package:flutter/material.dart';
import '../models/info_manager.dart'; // 引用全局状态管理器

class PromptGenerationScreen extends StatefulWidget {
  const PromptGenerationScreen({super.key});

  @override
  PromptGenerationScreenState createState() => PromptGenerationScreenState();
}

class PromptGenerationScreenState extends State<PromptGenerationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Generate'),
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

  Widget _buildResponsiveLayout() {
    var size = MediaQuery.of(context).size;
    bool useRow = size.width > size.height; // 当屏幕宽度大于高度时使用Row

    var content = [
      InfoManager().img == null
          ? const SizedBox.shrink()
          : Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: InfoManager().img!,
              ),
            ),
      Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListTile(
            title: const Text("Log"),
            subtitle: SingleChildScrollView(
              reverse: true,
              child: Text(InfoManager().log),
            ),
            dense: true,
          ),
        ),
      ),
    ];

    if (useRow) {
      return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: content,
          ));
    } else {
      return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: content,
          ));
    }
  }
}
