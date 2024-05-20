import 'package:flutter/material.dart';
import '../models/info_manager.dart';
import '../models/prompt_config.dart';

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
            child: InfoManager().promptsGenerator?.config != null
                ? _buildConfigTile(InfoManager().promptsGenerator!.config!, 0)
                : const ListTile(
                    title: Text('No configuration loaded'),
                  ),
          ),
        ));
  }

  Widget _buildConfigTile(PromptConfig config, int depth) {
    List<Widget> children = [];

    // Handle other properties of PromptConfig in a ListView to preserve the previous style
    children.addAll(_buildAdditionalProperties(config, depth));

    // Handle 'str' type prompts with individual line display in a single Text widget
    if (config.type == 'str') {
      String promptsText = config.prompts
          .join('\n'); // Join all strings with a newline character
      children.add(Padding(
        padding: EdgeInsets.only(
            left: depth * 20.0 + 20.0), // Increase padding for str items
        child: ExpansionTile(
          title: const Text('String Values'),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(promptsText,
                    softWrap: true,
                    textAlign: TextAlign.left), // Text aligned left
              ),
            )
          ],
        ),
      ));
    } else if (config.type == 'config') {
      for (var promptConfig in config.prompts) {
        if (promptConfig is PromptConfig) {
          children.add(_buildConfigTile(promptConfig, depth + 1));
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(left: depth * 20.0),
      child: ExpansionTile(
        initiallyExpanded: true,
        title:
            Text(config.comment.isNotEmpty ? config.comment : 'Unnamed Config'),
        subtitle: Text('Type: ${config.type}'),
        children: children,
      ),
    );
  }

  List<Widget> _buildAdditionalProperties(PromptConfig config, int depth) {
    List<Widget> properties = [];
    double indent =
        depth * 20.0 + 20.0; // Increment indent for additional properties
    if (config.selectionMethod != null) {
      properties.add(Padding(
        padding: EdgeInsets.only(left: indent),
        child: ListTile(
          title: Text('Selection Method: ${config.selectionMethod}'),
          tileColor: Colors.grey[200],
        ),
      ));
    }
    if (config.shuffled != null) {
      properties.add(Padding(
        padding: EdgeInsets.only(left: indent),
        child: ListTile(
          title: Text('Shuffled: ${config.shuffled}'),
          tileColor: Colors.grey[200],
        ),
      ));
    }
    if (config.prob != null) {
      properties.add(Padding(
        padding: EdgeInsets.only(left: indent),
        child: ListTile(
          title: Text('Probability: ${config.prob}'),
          tileColor: Colors.grey[200],
        ),
      ));
    }
    if (config.num != null) {
      properties.add(Padding(
        padding: EdgeInsets.only(left: indent),
        child: ListTile(
          title: Text('Number: ${config.num}'),
          tileColor: Colors.grey[200],
        ),
      ));
    }

    return properties;
  }
}
