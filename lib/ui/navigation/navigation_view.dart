import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/data/services/config_service.dart';
import 'package:nai_casrand/ui/generation_config_page/generation_config_page_view.dart';
import 'package:nai_casrand/ui/generation_config_page/generation_config_page_viewmodel.dart';
import 'package:nai_casrand/ui/generation_page/generation_page_view.dart';
import 'package:nai_casrand/ui/generation_page/generation_page_viewmodel.dart';
import 'package:nai_casrand/ui/navigation/navigation_viewmodel.dart';
import 'package:nai_casrand/ui/settings_page/settings_page_view.dart';
import 'package:nai_casrand/ui/settings_page/settings_page_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationView extends StatelessWidget {
  final NavigationViewModel viewmodel;

  const NavigationView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final payloadConfig = GetIt.instance<PayloadConfig>();
    final appBar = AppBar(
        title: Row(
      children: [
        Text('NAI CasRand'),
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
    ));
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
                          appBar: appBar,
                          body: Row(
                            children: [
                              NavigationRail(
                                selectedIndex: viewmodel.currentPageIndex,
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
                                  child: pages[
                                      viewmodel.currentPageIndex]), // 内容区域
                            ],
                          ));
                    } else {
                      // 纵向布局（BottomNavigationBar）
                      return Scaffold(
                        appBar: appBar,
                        body: Center(
                            child: pages[viewmodel.currentPageIndex]), // 内容区域
                        bottomNavigationBar: BottomNavigationBar(
                          currentIndex: viewmodel.currentPageIndex,
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
    final qrCode1Bytes = await viewmodel.decryptAsset('assets/qrcode1.jpg');
    final qrCode2Bytes = await viewmodel.decryptAsset('assets/qrcode2.jpg');
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
}
