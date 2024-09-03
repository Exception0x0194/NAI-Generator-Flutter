import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../widgets/model-widgets/prompt_config_widget.dart';
import '../models/info_manager.dart';

class PromptConfigScreen extends StatefulWidget {
  const PromptConfigScreen({super.key});

  @override
  PromptConfigScreenState createState() => PromptConfigScreenState();
}

class PromptConfigScreenState extends State<PromptConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
                title: Text(context.tr('prompt_compact_view_hint')),
                dense: true),
            CompactPromptConfigWidget(
              config: InfoManager().promptConfig,
              indentLevel: 0,
            ),
          ],
        ),
      ),
    );
  }
}
