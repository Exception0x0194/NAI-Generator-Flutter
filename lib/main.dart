import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/data/models/command_status.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/data/services/config_service.dart';
import 'package:nai_casrand/ui/navigation/widgets/navigation_view.dart';
import 'package:nai_casrand/ui/navigation/view_models/navigation_view_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  GetIt.instance.registerLazySingleton<ConfigService>(() => ConfigService());
  final configService = GetIt.instance<ConfigService>();
  configService.packageInfo = await PackageInfo.fromPlatform();
  final savedConfig = await configService.loadSavedConfig();

  GetIt.instance.registerLazySingleton<PayloadConfig>(
      () => PayloadConfig.fromJson(savedConfig));

  GetIt.instance.registerLazySingleton<CommandStatus>(() => CommandStatus());

  final appWithLocales = EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('zh', 'CN')],
    path: 'assets/l10n',
    child: const MyApp(),
  );

  runApp(appWithLocales);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pinkAccent,
            brightness: Brightness.light,
          ),
          useMaterial3: true),
      dark: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pinkAccent,
            brightness: Brightness.dark,
          ),
          useMaterial3: true),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        theme: theme,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: NavigationView(viewModel: NavigationViewModel()),
      ),
    );
  }
}
