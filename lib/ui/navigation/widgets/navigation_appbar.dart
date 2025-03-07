import 'dart:math';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:nai_casrand/data/models/command_status.dart';
import 'package:nai_casrand/data/services/config_service.dart';
import 'package:nai_casrand/data/services/file_service.dart';
import 'package:nai_casrand/ui/navigation/widgets/debug_settings_view.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppState { idle, generating, coolingDown }

class NavigationAppBar extends StatefulWidget implements PreferredSizeWidget {
  final CommandStatus commandStatus = GetIt.instance();

  NavigationAppBar({super.key});

  @override
  NavigationAppBarState createState() => NavigationAppBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // 默认的AppBar高度
}

class NavigationAppBarState extends State<NavigationAppBar>
    with SingleTickerProviderStateMixin {
  late final _iconAnimationController = AnimationController(
    duration: const Duration(seconds: 3), // 控制旋转速度
    vsync: this,
  );
  late final _animation = CurvedAnimation(
    parent: _iconAnimationController,
    curve: Curves.linear,
  );
  AppState _state = AppState.idle;

  @override
  void initState() {
    super.initState();

    // 在生成状态变化时改变样式
    widget.commandStatus.isBatchActive.addListener(refreshDisplay);
    widget.commandStatus.isCoolingDown.addListener(refreshDisplay);
    refreshDisplay(); // 初始化状态
  }

  void refreshDisplay() {
    AppState newState;
    if (widget.commandStatus.isCoolingDown.value) {
      newState = AppState.coolingDown;
    } else if (widget.commandStatus.isBatchActive.value) {
      newState = AppState.generating;
    } else {
      newState = AppState.idle;
    }
    setState(() => _state = newState);
  }

  @override
  Widget build(BuildContext context) {
    Widget title;
    switch (_state) {
      case AppState.idle:
        title = Text(
          context.tr('appbar_idle'),
        );
        _iconAnimationController.stop();
        break;
      case AppState.generating:
        title = BlinkText(
          context.tr('appbar_regular'),
          beginColor: Theme.of(context).textTheme.titleMedium?.color,
        );
        _iconAnimationController.repeat();
        break;
      case AppState.coolingDown:
        title = BlinkText(
          context.tr('appbar_cooldown'),
          beginColor: Theme.of(context).textTheme.titleMedium?.color,
        );
        _iconAnimationController.stop();
        break;
    }
    Widget icon = RotationTransition(
        turns: _animation,
        child: Image.asset(
          'assets/appicon.png',
          filterQuality: FilterQuality.medium,
          height: widget.preferredSize.height - 16.0,
        ));
    final titleBar = Row(
      children: [
        InkWell(
          child: icon,
          onTap: () => _iconAnimationController
              .animateTo(Random().nextDouble())
              .whenComplete(refreshDisplay),
        ),
        const SizedBox(width: 8.0),
        InkWell(
          child: title,
          onTap: () => _showDebugDialog(context),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _showAppInfoDialog(context),
          icon: const Icon(Icons.help_outline),
        ),
      ],
    );
    return AppBar(
      title: titleBar,
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    final packageInfo = GetIt.instance<ConfigService>().packageInfo;
    const appName = 'NAI CasRand';
    final appVersion = packageInfo.version;
    final iconImage = Image.asset(
      'assets/appicon.png',
      width: 64,
      height: 64,
      filterQuality: FilterQuality.medium,
    );

    showAboutDialog(
        context: context,
        applicationName: appName,
        applicationVersion: appVersion,
        applicationIcon: iconImage,
        children: [
          // Github link
          _buildLinkTile(),
          // Donation link
          _buildDonationLink(context)
        ]);
  }

  Widget _buildLinkTile() {
    return ListTile(
      title: Text(tr('github_repo')),
      leading: const Icon(Icons.link),
      subtitle: const Text(String.fromEnvironment("GITHUB_REPO_LINK")),
      onTap: () => {
        launchUrl(Uri.parse(const String.fromEnvironment("GITHUB_REPO_LINK")))
      },
    );
  }

  Widget _buildDonationLink(BuildContext context) {
    return ListTile(
      title: Text(tr('donation_link')),
      subtitle: Text(tr('donation_link_subtitle')),
      leading: const Icon(Icons.favorite_border),
      onTap: () => _showDonationQRCode(context),
    );
  }

  void _showDonationQRCode(BuildContext context) async {
    final qrCode1Bytes = await FileService().decryptAsset('assets/qrcode1.jpg');
    final qrCode2Bytes = await FileService().decryptAsset('assets/qrcode2.jpg');
    if (qrCode1Bytes == null || qrCode2Bytes == null || !context.mounted) {
      return;
    }

    const qrCodeSize = 200.0;
    final qrCode1 = Image.memory(
      qrCode1Bytes,
      width: qrCodeSize,
      height: qrCodeSize,
      filterQuality: FilterQuality.medium,
    );
    final qrCode2 = Image.memory(
      qrCode2Bytes,
      width: qrCodeSize,
      height: qrCodeSize,
      filterQuality: FilterQuality.medium,
    );
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(tr('donation_link_subtitle')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  qrCode1,
                  const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                  qrCode2,
                ],
              ),
            ));
  }

  void _showDebugDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Debug Settings'),
              content: DebugSettingsView(),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      tr('confirm'),
                    ))
              ],
            ));
  }
}
