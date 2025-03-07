import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/ui/config_page/widgets/config_page_view.dart';
import 'package:nai_casrand/ui/config_page/view_models/config_page_viewmodel.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:nai_casrand/ui/generation_page/widgets/generation_page_view.dart';
import 'package:nai_casrand/ui/generation_page/view_models/generation_page_viewmodel.dart';
import 'package:nai_casrand/ui/navigation/view_models/navigation_view_model.dart';
import 'package:nai_casrand/ui/navigation/widgets/navigation_appbar.dart';
import 'package:nai_casrand/ui/settings_page/widgets/settings_page_view.dart';
import 'package:nai_casrand/ui/settings_page/view_models/settings_page_viewmodel.dart';

class NavigationView extends StatefulWidget {
  final NavigationViewModel viewModel;

  const NavigationView({super.key, required this.viewModel});

  @override
  State<StatefulWidget> createState() => NavigationViewState();
}

class NavigationViewState extends State<NavigationView> {
  int _currentIndex = 0;

  DateTime? _lastBackButtonPressTime;

  void _changeIndex(int value) {
    widget.viewModel.changeIndex(value);
    setState(() {
      _currentIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final payloadConfig = GetIt.instance<PayloadConfig>();
    final pages = [
      GenerationPageView(
        viewmodel: GenerationPageViewmodel(payloadConfig: payloadConfig),
      ),
      ConfigPageView(
        viewmodel: ConfigPageViewmodel(payloadConfig: payloadConfig),
      ),
      SettingsPageView(
        viewmodel: SettingsPageViewmodel(payloadConfig: payloadConfig),
      ),
    ];
    final appBar = NavigationAppBar();
    final content = LayoutBuilder(
      builder: (context, constraints) {
        // 使用 LayoutBuilder 来监听父容器的宽度变化
        bool isHorizontal = constraints.maxWidth >= 640;
        if (isHorizontal) {
          // 横向布局 (Row - NavigationRail)
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _changeIndex,
                labelType: NavigationRailLabelType.all,
                groupAlignment: -1.0,
                destinations: [
                  NavigationRailDestination(
                      icon: const Icon(Icons.create),
                      label: Text(context.tr('generation'))),
                  NavigationRailDestination(
                      icon: const Icon(Icons.visibility),
                      label: Text(context.tr('prompt_config'))),
                  NavigationRailDestination(
                      icon: const Icon(Icons.settings),
                      label: Text(context.tr('settings'))),
                ],
              ),
              Expanded(child: pages[_currentIndex]), // 内容区域
            ],
          );
        } else {
          // 纵向布局 (Column - BottomNavigationBar)
          return Column(
            children: [
              Expanded(child: pages[_currentIndex]), // 内容区域
              BottomNavigationBar(
                currentIndex: _currentIndex,
                items: [
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.create),
                      label: context.tr('generation')),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.visibility),
                      label: context.tr('prompt_config')),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.settings),
                      label: context.tr('settings')),
                ],
                onTap: _changeIndex,
              )
            ],
          );
        }
      },
    );
    final body = Scaffold(
      appBar: appBar,
      body: Center(child: content), // 内容区域
    );
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          // 使用 onPopInvoked 回调
          final now = DateTime.now();
          final timeDiff = _lastBackButtonPressTime == null
              ? null
              : now.difference(_lastBackButtonPressTime!);
          if (timeDiff == null || timeDiff > const Duration(seconds: 2)) {
            _lastBackButtonPressTime = now;
            showInfoBar(context, tr('press_again_to_exit')); // 提示用户双击退出
            return; // 阻止默认的 pop 行为
          } else {
            SystemNavigator.pop(); // 双击，退出应用
          }
        },
        child: body);
  }
}
