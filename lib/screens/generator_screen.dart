import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/info_manager.dart'; // 引用全局状态管理器

class PromptGenerationScreen extends StatefulWidget {
  const PromptGenerationScreen({super.key});

  @override
  PromptGenerationScreenState createState() => PromptGenerationScreenState();
}

class PromptGenerationScreenState extends State<PromptGenerationScreen> {
  String _displayedText = "Please load a config to generate prompts.";

  void _generatePrompt() {
    var requestData = InfoManager().getRequestData();
    setState(() {
      _displayedText =
          '${requestData['comment']}\n\n${json.encode(requestData['body'])}';
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
            ElevatedButton(
              onPressed: () {
                saveFile('Hello, world! This is a random file.').then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('File saved successfully!')));
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save file: $error')));
                });
              },
              child: Text('Save Random File'),
            ),
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

  Future<void> saveFile(String content) async {
    if (kIsWeb) {
      // 对 Web 平台的处理
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "random_file_${Random().nextInt(1000)}.txt")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // 对移动或桌面平台的处理
      final path = await getFilePath();
      final fileName = "random_file_${Random().nextInt(1000)}.txt";
      final file = File('$path/$fileName');
      await file.writeAsString(content);
      print('File saved: $file');
    }
  }

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory(); // 获取文档目录的路径
    return directory.path;
  }

  Future<void> saveRandomFile() async {
    final path = await getFilePath();
    final fileName = "random_file_${Random().nextInt(1000)}.txt"; // 随机文件名
    final file = File('$path/$fileName');

    // 写入内容到文件
    await file.writeAsString('Hello, world! This is a random file.');
    print('File saved: $file');
  }
}
