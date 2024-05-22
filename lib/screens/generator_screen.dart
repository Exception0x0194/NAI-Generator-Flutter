import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/info_manager.dart'; // 引用全局状态管理器

class PromptGenerationScreen extends StatefulWidget {
  const PromptGenerationScreen({super.key});

  @override
  PromptGenerationScreenState createState() => PromptGenerationScreenState();
}

class PromptGenerationScreenState extends State<PromptGenerationScreen> {
  String _displayedText = "Please load a config to generate prompts.";

  void _generatePrompt() {
    var promptResult = InfoManager().promptConfig.pickPromptsFromConfig();
    Map<String, dynamic> requestData = {};
    requestData['input'] = promptResult['prompt'];
    requestData['model'] = "nai-diffusion-3";
    requestData['action'] = 'generate';
    requestData['parameters'] = InfoManager().paramConfig.toJson();
    setState(() {
      _displayedText =
          "${json.encode(requestData)}\n\n${promptResult['comment']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Request JSON'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _generatePrompt,
              child: const Text('Generate Prompt'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_displayedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
