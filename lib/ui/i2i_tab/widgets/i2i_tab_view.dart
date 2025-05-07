import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/i2i_tab/view_models/i2i_tab_viewmodel.dart';
import 'package:nai_casrand/ui/vibe_config/view_models/vibe_config_list_viewmodel.dart';
import 'package:nai_casrand/ui/vibe_config/widgets/vibe_config_list_view.dart';
import 'package:nai_casrand/ui/vibe_config_v4/viewmodels/vibe_config_v4_list_viewmodel.dart';
import 'package:nai_casrand/ui/vibe_config_v4/widgets/vibe_config_v4_list_view.dart';

class I2iTabView extends StatelessWidget {
  final I2iTabViewmodel viewmodel;

  const I2iTabView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final vibeWidget = viewmodel.isV4
        ? VibeConfigV4ListView(viewmodel: VibeConfigV4ListViewmodel())
        : VibeConfigListView(viewmodel: VibeConfigListViewmodel());

    return vibeWidget;
  }
}
