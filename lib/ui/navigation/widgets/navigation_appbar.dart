import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
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
  AnimationController? _animationController;
  Animation<Color?>? _colorAnimation;
  Color _staticColor = Colors.transparent;
  String _currentTitle = '';
  AppState _state = AppState.idle;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1), // 控制闪烁速度
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.yellow,
    ).animate(_animationController!)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController!.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController!.forward();
        }
      });

    // 在生成状态变化时改变样式
    widget.commandStatus.isBatchActive.addListener(refreshDisplay);
    widget.commandStatus.isCoolingDown.addListener(refreshDisplay);
    refreshDisplay(); // 初始化状态
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
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

    // Change display only on status is changed
    if (newState == _state) return;
    _state = newState;

    switch (_state) {
      case AppState.idle:
        _animationController!.stop();
        _colorAnimation = null;
        _animationController!.value = 0.0;
        _staticColor = Colors.transparent;
        break;
      case AppState.generating:
        _colorAnimation =
            ColorTween(begin: Colors.transparent, end: Colors.yellow)
                .animate(_animationController!);
        _animationController!.forward();
        break;
      case AppState.coolingDown:
        _animationController!.stop();
        _colorAnimation = null;
        _animationController!.value = 0.0;
        _staticColor = Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case AppState.idle:
        _currentTitle = context.tr('appbar_idle');
        break;
      case AppState.generating:
        _currentTitle = context.tr('appbar_regular');
        break;
      case AppState.coolingDown:
        _currentTitle = context.tr('appbar_cooldown');
        break;
    }
    final titleBar = Row(
      children: [
        InkWell(
          child: Text(_currentTitle),
          onTap: () => _showDebugDialog(context),
        ),
        Spacer(),
        IconButton(
          onPressed: () => _toggleDark(context),
          icon: Icon(Icons.dark_mode_outlined),
        ),
        SizedBox(width: 20.0),
        IconButton(
          onPressed: () => _showLanguageSelectionDialog(context),
          icon: Icon(Icons.translate),
        ),
        SizedBox(width: 20.0),
        IconButton(
          onPressed: () => _showAppInfoDialog(context),
          icon: Icon(Icons.help_outline),
        ),
      ],
    );
    return AppBar(
      backgroundColor: _colorAnimation?.value ??
          _staticColor, // Use static color for default
      title: titleBar,
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    final locales = context.supportedLocales;
    String getLocaleName(Locale locale) {
      if (locale.countryCode == null) {
        return locale.languageCode;
      } else {
        return '${locale.languageCode}-${locale.countryCode}';
      }
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Select language...'),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: locales
                        .map((l) => ListTile(
                              title: Text(getLocaleName(l)),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.setLocale(l);
                              },
                            ))
                        .toList()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(context.tr('confirm')))
                ]));
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

  void _toggleDark(BuildContext context) {
    final brightness = AdaptiveTheme.of(context).brightness;
    if (brightness == Brightness.light) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
  }

  void _showDebugDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Debug Settings'),
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
