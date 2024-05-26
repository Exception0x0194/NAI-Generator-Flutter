import 'package:flutter/material.dart';
import '../models/info_manager.dart';
import '../widgets/prompt_config_widget.dart';

class PromptConfigScreen extends StatefulWidget {
  const PromptConfigScreen({super.key});

  @override
  PromptConfigScreenState createState() => PromptConfigScreenState();
}

class PromptConfigScreenState extends State<PromptConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Configuration'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(right: 0),
        child: PromptConfigWidget(
          config: InfoManager().promptConfig, // 使用全局配置
          indentLevel: 0,
        ),
      )),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Toggle compact view',
        onPressed: () => {
          setState(() {
            InfoManager().showPromptParameters =
                !InfoManager().showPromptParameters;
          })
        },
        child: InfoManager().showPromptParameters
            ? const Icon(Icons.visibility_off)
            : const Icon(Icons.visibility),
      ),
    );
  }
}
