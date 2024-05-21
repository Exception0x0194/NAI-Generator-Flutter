import 'package:flutter/material.dart';
import '../models/info_manager.dart';
import '../models/prompt_config.dart';
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
        child: PromptConfigWidget(
          config: InfoManager().config, // 使用全局配置
          indentLevel: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                copyConfigToClipboard(InfoManager().config);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exported to clipboard')));
              },
              tooltip: 'Export to clipboard',
              child: const Icon(Icons.save),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: () async {
                PromptConfig? newConfig = await getConfigFromClipboard();
                if (newConfig != null) {
                  setState(() {
                    InfoManager().config = newConfig;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Imported from clipboard')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import failed')));
                }
              },
              tooltip: 'Import from clipboard',
              child: const Icon(Icons.file_upload),
            ),
          ],
        ),
      ),
    );
  }
}
