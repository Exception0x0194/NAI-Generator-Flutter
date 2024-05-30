import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/info_manager.dart';
import '../models/global_settings.dart';
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
        title: Text(S.of(context).prompt_config),
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
        tooltip: S.of(context).toggle_compact_view,
        onPressed: () => {
          setState(() {
            GlobalSettings().showCompactPromptView =
                !GlobalSettings().showCompactPromptView;
          })
        },
        child: GlobalSettings().showCompactPromptView
            ? const Icon(Icons.visibility_off)
            : const Icon(Icons.visibility),
      ),
    );
  }
}
