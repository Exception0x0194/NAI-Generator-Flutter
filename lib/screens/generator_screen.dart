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
    var requestData = InfoManager().getRequestBody();
    setState(() {
      _displayedText = json.encode(requestData);
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
            ElevatedButton(
              onPressed: InfoManager().generateImage,
              child: const Text('Generate Image'),
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
