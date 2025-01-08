import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/services/config_service.dart';
import 'package:nai_casrand/ui/generation_config_page/generation_config_page_view.dart';
import 'package:nai_casrand/ui/generation_config_page/generation_config_page_viewmodel.dart';
import 'package:nai_casrand/ui/generation_page/generation_page_view.dart';
import 'package:nai_casrand/ui/navigation/navigation_viewmodel.dart';
import 'package:nai_casrand/ui/settings_page/settings_page_view.dart';
import 'package:provider/provider.dart';

class NavigationView extends StatelessWidget {
  final NavigationViewModel viewmodel;

  const NavigationView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final configservice = GetIt.instance<ConfigService>();
    final pages = [
      GenerationPageView(),
      GenerationConfigPageView(
          viewmodel:
              GenerationConfigPageViewmodel(configService: configservice)),
      SettingsPageView(),
    ];
    return ChangeNotifierProvider.value(
      value: viewmodel,
      child: Consumer<NavigationViewModel>(
          builder: (context, viewModel, child) => Scaffold(
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    // 使用 LayoutBuilder 来监听父容器的宽度变化
                    bool isHorizontal = constraints.maxWidth >= 640;
                    if (isHorizontal) {
                      // 横向布局（NavigationRail）
                      return Scaffold(
                          appBar: AppBar(title: Text('Horizontal Navigation')),
                          body: Row(
                            children: [
                              NavigationRail(
                                selectedIndex: viewmodel.currentIndex,
                                onDestinationSelected: (index) =>
                                    viewmodel.changeIndex(index),
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
                                  child: pages[viewmodel.currentIndex]), // 内容区域
                            ],
                          ));
                    } else {
                      // 纵向布局（BottomNavigationBar）
                      return Scaffold(
                        appBar: AppBar(title: Text("Vertical Navigation")),
                        body: Center(
                            child: pages[viewmodel.currentIndex]), // 内容区域
                        bottomNavigationBar: BottomNavigationBar(
                          currentIndex: viewmodel.currentIndex,
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
                          onTap: (index) => viewmodel.changeIndex(index),
                        ),
                      );
                    }
                  },
                ),
              )),
    );
  }
}
