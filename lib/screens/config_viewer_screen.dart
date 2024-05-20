import 'package:flutter/material.dart';
import '../models/info_manager.dart';  // 引用全局状态管理器
import '../models/prompt_config.dart';  // 确保引入了PromptConfig

class ConfigViewerScreen extends StatelessWidget {
  const ConfigViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Config Viewer'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildConfigTile(InfoManager().promptsGenerator?.config),
        ),
      ),
    );
  }

  Widget _buildConfigTile(PromptConfig? config) {
    if (config == null) {
      return const ListTile(
        title: Text('No configuration loaded'),
      );
    }

    List<Widget> children = [];
    if (config.prompts.isNotEmpty) {
      for (var promptConfig in config.prompts) {
        children.add(_buildConfigTile(promptConfig));
      }
    }

    return ExpansionTile(
      title: Text(config.comment.isNotEmpty ? config.comment : 'Unnamed Config'),
      subtitle: Text('Type: ${config.type}'),
      children: children,
    );
  }
}
