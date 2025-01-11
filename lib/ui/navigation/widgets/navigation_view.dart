import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/ui/generation_config_page/generation_config_page_view.dart';
import 'package:nai_casrand/ui/generation_config_page/generation_config_page_viewmodel.dart';
import 'package:nai_casrand/ui/generation_page/generation_page_view.dart';
import 'package:nai_casrand/ui/generation_page/generation_page_viewmodel.dart';
import 'package:nai_casrand/ui/navigation/view_models/navigation_view_model.dart';
import 'package:nai_casrand/ui/navigation/widgets/navigation_appbar.dart';
import 'package:nai_casrand/ui/settings_page/settings_page_view.dart';
import 'package:nai_casrand/ui/settings_page/settings_page_viewmodel.dart';
import 'package:provider/provider.dart';

class NavigationView extends StatelessWidget {
  final NavigationViewModel viewModel;

  const NavigationView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final payloadConfig = GetIt.instance<PayloadConfig>();
    final pages = [
      GenerationPageView(
        viewmodel: GenerationPageViewmodel(payloadConfig: payloadConfig),
      ),
      GenerationConfigPageView(
        viewmodel: GenerationConfigPageViewmodel(payloadConfig: payloadConfig),
      ),
      SettingsPageView(
        viewmodel: SettingsPageViewmodel(payloadConfig: payloadConfig),
      ),
    ];
    final appBar = NavigationAppBar(viewModel: viewModel);
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<NavigationViewModel>(
          builder: (context, viewModel, child) => Scaffold(
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    // 使用 LayoutBuilder 来监听父容器的宽度变化
                    bool isHorizontal = constraints.maxWidth >= 640;
                    if (isHorizontal) {
                      // 横向布局（NavigationRail）
                      return Scaffold(
                          appBar: appBar,
                          body: Row(
                            children: [
                              NavigationRail(
                                selectedIndex: viewModel.currentPageIndex,
                                onDestinationSelected: (index) =>
                                    viewModel.changeIndex(index),
                                labelType: NavigationRailLabelType.all,
                                groupAlignment: -1.0,
                                destinations: [
                                  NavigationRailDestination(
                                      icon: Icon(Icons.create),
                                      label: Text(context.tr('generation'))),
                                  NavigationRailDestination(
                                      icon: Icon(Icons.visibility),
                                      label: Text(context.tr('prompt_config'))),
                                  NavigationRailDestination(
                                      icon: Icon(Icons.settings),
                                      label: Text(context.tr('settings'))),
                                ],
                              ),
                              Expanded(
                                  child: pages[
                                      viewModel.currentPageIndex]), // 内容区域
                            ],
                          ));
                    } else {
                      // 纵向布局（BottomNavigationBar）
                      return Scaffold(
                        appBar: appBar,
                        body: Center(
                            child: pages[viewModel.currentPageIndex]), // 内容区域
                        bottomNavigationBar: BottomNavigationBar(
                          currentIndex: viewModel.currentPageIndex,
                          items: [
                            BottomNavigationBarItem(
                                icon: Icon(Icons.create),
                                label: context.tr('generation')),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.visibility),
                                label: context.tr('prompt_config')),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.settings),
                                label: context.tr('settings')),
                          ],
                          onTap: (index) => viewModel.changeIndex(index),
                        ),
                      );
                    }
                  },
                ),
              )),
    );
  }
}
