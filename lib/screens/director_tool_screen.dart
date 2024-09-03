import 'package:flutter/material.dart';

import '../models/info_manager.dart';
import '../widgets/model-widgets/director_tool_widget.dart';

class DirectorToolScreen extends StatelessWidget {
  const DirectorToolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: DirectorToolWidget(
          config: InfoManager().directorToolConfig,
        ),
      ),
    );
  }
}
