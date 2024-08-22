import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:nai_casrand/screens/director_tool_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'screens/generator_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/prompt_config_screen.dart';
import 'screens/i2i_config_screen.dart';
import 'widgets/flashing_appbar.dart';
import 'models/info_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final app = ChangeNotifierProvider(
    create: (context) => InfoManager(),
    child: const MyApp(),
  );

  final appWithLocales = EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('zh', 'CN')],
    path: 'assets/l10n',
    child: app,
  );

  runApp(appWithLocales);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
          useMaterial3: true),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late Future _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _loadInitialInfo();
    // Call welcome dialog at startup AFTER build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      if (version != InfoManager().firstSetupVersion) {
        _showFirstSetupDialog(version);
      }
    });
  }

  @override
  void dispose() {
    // Closes all Hive boxes
    InfoManager().saveConfig();
    Hive.close();
    super.dispose();
  }

  void _onItemTapped(int index) {
    InfoManager().saveConfig();
    setState(() {
      _selectedIndex = index;
    });
  }

  Future _loadInitialInfo() async {
    if (!kIsWeb) {
      final dir = await getApplicationCacheDirectory();
      Hive.init(dir.path);
    }
    InfoManager().saveBox = await Hive.openBox('savedBox');
    var jsonData = InfoManager().saveBox.get('savedConfig');
    jsonData =
        jsonData ?? await rootBundle.loadString('assets/json/example.json');
    InfoManager().fromJson(json.decode(jsonData));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            // ignore: prefer_const_constructors
            appBar: FlashingAppBar(),
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                Consumer<InfoManager>(builder: (context, manager, child) {
                  // ignore: prefer_const_constructors
                  return PromptGenerationScreen();
                }),
                // ignore: prefer_const_constructors
                PromptConfigScreen(),
                // ignore: prefer_const_constructors
                I2IConfigScreen(),
                // ignore: prefer_const_constructors
                DirectorToolScreen(),
                // ignore: prefer_const_constructors
                SettingsScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(Icons.create),
                  label: context.tr('generation'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.visibility),
                  label: context.tr('prompt_config'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.screen_rotation),
                  label: context.tr('i2i_config'),
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.open_in_new),
                  label: 'Director Tool',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: context.tr('settings'),
                )
              ],
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              onTap: _onItemTapped,
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _showFirstSetupDialog(String version) {
    const linkStyle =
        TextStyle(color: Colors.blue, decoration: TextDecoration.underline);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.tr('welcome_message_title')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        TextSpan(text: context.tr('welcome_message_para1')),
                        TextSpan(children: [
                          TextSpan(text: context.tr('welcome_message_para2_1')),
                          TextSpan(
                              text: context.tr('welcome_message_para2_2'),
                              style: linkStyle,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _selectedIndex = 4;
                                  });
                                }),
                          TextSpan(text: context.tr('welcome_message_para2_3')),
                        ]),
                        TextSpan(children: [
                          TextSpan(text: context.tr('welcome_message_para3_1')),
                          TextSpan(
                              text: context.tr('welcome_message_para3_2'),
                              style: linkStyle,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrl(Uri.parse(
                                      'https://github.com/Exception0x0194/NAI-Generator-Flutter'));
                                }),
                          TextSpan(text: context.tr('welcome_message_para3_3')),
                          TextSpan(
                              text: context.tr('welcome_message_para3_4'),
                              style: linkStyle,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrl(
                                      Uri.parse('mailto:1009535916@qq.com'));
                                }),
                          TextSpan(text: context.tr('welcome_message_para3_5')),
                        ])
                      ])),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      InfoManager().firstSetupVersion = version;
                    },
                    child: Text(context.tr('dont_show_again'))),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(context.tr('confirm'))),
              ],
            ));
  }
}
