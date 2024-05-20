import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/info_manager.dart';  // 引用全局状态管理器

class PromptGenerationScreen extends StatefulWidget {
  @override
  _PromptGenerationScreenState createState() => _PromptGenerationScreenState();
}

class _PromptGenerationScreenState extends State<PromptGenerationScreen> {
  String _displayedText = "Please load a config to generate prompts.";

  void _loadJsonConfig() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String fileContent = utf8.decode(result.files.single.bytes!);
        Map<String, dynamic> jsonData = jsonDecode(fileContent);
        InfoManager().loadPrompts(jsonData);
        setState(() {
          _displayedText = "Config loaded successfully!";
        });
      }
    } catch (e) {
      setState(() {
        _displayedText = "Error loading config: $e";
      });
    }
  }

  void _generatePrompt() {
    if (InfoManager().promptsGenerator != null) {
      var promptResult = InfoManager().promptsGenerator!.getPrompt();
      setState(() {
        _displayedText = "${promptResult['prompt']} ${promptResult['comment']}";
      });
    } else {
      setState(() {
        _displayedText = "Please load a config to generate prompts.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Prompts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _loadJsonConfig,
              child: Text('Load Config'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generatePrompt,
              child: Text('Generate Prompt'),
            ),
            SizedBox(height: 20),
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
