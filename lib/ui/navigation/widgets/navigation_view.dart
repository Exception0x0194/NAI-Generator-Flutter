import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/ui/config_page/widgets/config_page_view.dart';
import 'package:nai_casrand/ui/config_page/view_models/config_page_viewmodel.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:nai_casrand/ui/generation_page/widgets/generation_page_view.dart';
import 'package:nai_casrand/ui/navigation/view_models/navigation_view_model.dart';
import 'package:nai_casrand/ui/navigation/widgets/metadata_drop_area.dart';
import 'package:nai_casrand/ui/navigation/widgets/navigation_appbar.dart';
import 'package:nai_casrand/ui/settings_page/widgets/settings_page_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/payload_config.dart';
import '../../../data/services/config_service.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = NavigationAppBar();
    final body = Scaffold(
      appBar: appBar,
      body: MetadataDropArea(
        childBuilder: (context) => getBody(),
      ),
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

  Widget getBody() {
    final pages = [
      GenerationPageView(viewmodel: GetIt.I()),
      ConfigPageView(
        viewmodel: ConfigPageViewmodel(),
      ),
      SettingsPageView(),
    ];
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
    return Center(child: content);
  }

  void _showWelcomeDialog() {
    final dontShowAgainVersion =
        GetIt.I<PayloadConfig>().settings.welcomeMessageVersion;
    final packageInfo = GetIt.instance<ConfigService>().packageInfo;
    const appName = 'Nai CasRand';
    final appVersion = packageInfo.version;
    if (appVersion == dontShowAgainVersion) return;
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title:
                Text('${tr('welcome_message_title')} - $appName $appVersion'),
            content: MarkdownBody(
              data: tr('welcome_message_markdown'),
              onTapLink: (text, url, title) {
                if (url == null) return;
                if (url == '#jump_to_settings') {
                  // Jump to settings page
                  _changeIndex(2);
                  Navigator.of(dialogContext).pop();
                } else {
                  // Launch link
                  launchUrl(Uri.parse(url));
                }
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    GetIt.I<PayloadConfig>().settings.welcomeMessageVersion =
                        appVersion;
                    // Save the config
                    final config = GetIt.instance<PayloadConfig>();
                    final service = GetIt.instance<ConfigService>();
                    service.saveConfig(config.toJson());
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(tr('dont_show_again'))),
              TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(tr('confirm')))
            ],
          );
        });
  }
}
