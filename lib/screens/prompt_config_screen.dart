
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       FloatingActionButton(
      //         onPressed: () async {
      //           await _loadJsonConfig();
      //         },
      //         tooltip: 'Import from file',
      //         child: const Icon(Icons.file_open),
      //       ),
      //       const SizedBox(height: 20),
      //       FloatingActionButton(
      //         onPressed: () async {
      //           Map<String, dynamic>? newConfig = await _getJsonFromClipboard();
      //           try {
      //             setState(() {
      //               InfoManager().promptConfig =
      //                   PromptConfig.fromJson(newConfig!, 0);
      //             });
      //             ScaffoldMessenger.of(context).showSnackBar(
      //                 const SnackBar(content: Text('Imported from clipboard')));
      //           } catch (e) {
      //             ScaffoldMessenger.of(context).showSnackBar(
      //                 const SnackBar(content: Text('Import failed')));
      //           }
      //         },
      //         tooltip: 'Import from clipboard',
      //         child: const Icon(Icons.upload),
      //       ),
      //       const SizedBox(height: 20),
      //       FloatingActionButton(
      //         onPressed: () {
      //           _copyConfigToClipboard();
      //           ScaffoldMessenger.of(context).showSnackBar(
      //               const SnackBar(content: Text('Exported to clipboard')));
      //         },
      //         tooltip: 'Export to clipboard',
      //         child: const Icon(Icons.save),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
