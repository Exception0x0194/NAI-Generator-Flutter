import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/config_page/generation_config_page_viewmodel.dart';
import 'package:nai_casrand/ui/config_page/i2i_tab/i2i_tab_view.dart';
import 'package:nai_casrand/ui/config_page/i2i_tab/i2i_tab_viewmodel.dart';
import 'package:nai_casrand/ui/config_page/parameters_tab/parameters_tab_view.dart';
import 'package:nai_casrand/ui/config_page/parameters_tab/parameters_tab_viewmodel.dart';
import 'package:nai_casrand/ui/config_page/prompt_tab/prompt_tab_view.dart';
import 'package:nai_casrand/ui/config_page/prompt_tab/prompt_tab_viewmodel.dart';

class GenerationConfigPageView extends StatelessWidget {
  final GenerationConfigPageViewmodel viewmodel;

  const GenerationConfigPageView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: const TabBar(
              tabs: [
                Tab(
                  text: 'Prompt Config',
                ),
                Tab(text: 'Vibe Transfer'),
                Tab(text: 'Parameters'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              PromptTabView(
                  viewmodel: PromptTabViewmodel(
                promptConfig: viewmodel.payloadConfig.rootPromptConfig,
                characterConfigList:
                    viewmodel.payloadConfig.characterConfigList,
              )),
              I2iTabView(
                viewmodel: I2iTabViewmodel(
                    vibeConfigList: viewmodel.payloadConfig.vibeConfigList),
              ),
              ParametersTabView(
                viewmodel: ParametersTabViewmodel(
                    config: viewmodel.payloadConfig.paramConfig),
              ),
            ],
          )),
    );
  }
}
