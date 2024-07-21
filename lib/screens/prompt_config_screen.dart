import 'package:flutter/material.dart';
import 'package:nai_casrand/widgets/compact_prompt_config_widget.dart';

import '../generated/l10n.dart';
import '../models/info_manager.dart';
import '../widgets/prompt_config_widget.dart';

class PromptConfigScreen extends StatefulWidget {
  const PromptConfigScreen({super.key});

  @override
  PromptConfigScreenState createState() => PromptConfigScreenState();
}

class PromptConfigScreenState extends State<PromptConfigScreen> {
  bool _showCompactView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _showCompactView
            ? Column(children: [
                ListTile(
                    title: Text(S.of(context).prompt_compact_view_hint),
                    dense: true),
                CompactPromptConfigWidget(
                    config: InfoManager().promptConfig, indentLevel: 0)
              ])
            : PromptConfigWidget(
                config: InfoManager().promptConfig,
                indentLevel: 0,
                showCompactView: false),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: S.of(context).toggle_compact_view,
        onPressed: () => {
          setState(() {
            _showCompactView = !_showCompactView;
          })
        },
        child: _showCompactView
            ? const Icon(Icons.visibility_off)
            : const Icon(Icons.visibility),
      ),
    );
  }
}
