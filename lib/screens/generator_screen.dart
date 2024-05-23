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
          child: Column(
            children: [
              Expanded(
                // 使用Expanded让ListView使用所有可用空间，但不会覆盖下方的按钮
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: ListTile(
                              title: const Text("Log"),
                              subtitle: SingleChildScrollView(
                                // 添加滚动
                                reverse: true,
                                // 添加滚动
                                child: Text(InfoManager().log),
                              ),
                              dense: true,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: InfoManager().img,
                          ),
                        ),
                      ],
                    )),
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                  onPressed: _generateImage,
                  tooltip: 'Generate one image',
                  child: const Icon(Icons.image)),
              const SizedBox(
                height: 20,
              ),
              FloatingActionButton(
                  onPressed: _toggleGeneration,
                  tooltip: 'Start generation',
                  child: InfoManager().isGenerating
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.alarm))
            ],
          ),
        ));
  }

  void _generateImage() async {
    InfoManager().generateImage();
  }

  void _toggleGeneration() async {
    InfoManager().isGenerating = !InfoManager().isGenerating;
    setState(() {});
    if (InfoManager().isGenerating) {
      _generateImage();
    }
  }
}
