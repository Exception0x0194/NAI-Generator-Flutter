// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'screens/generator_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/prompt_config_screen.dart';
import 'screens/director_tool_screen.dart';
import 'screens/i2i_config_screen.dart';
import 'widgets/flashing_appbar.dart';
import 'models/info_manager.dart';
import 'utils/flushbar.dart';

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

  DateTime? _lastPressed;

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.create,
      'label': 'generation', // 使用 l10n 中的 key
    },
    {
      'icon': Icons.visibility,
      'label': 'prompt_config',
    },
    {
      'icon': Icons.screen_rotation,
      'label': 'i2i_config',
    },
    {
      'icon': Icons.open_in_new,
      'label': 'director_tool',
    },
    {
      'icon': Icons.settings,
      'label': 'settings',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializationFuture = _loadInitialInfo();
    // Call welcome dialog at startup AFTER build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializationFuture;
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      final iVersion = InfoManager().welcomeMessageVersion;
      if (version != iVersion) {
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
    Directory dir;
    if (!kIsWeb) {
      // New hive box directory
      dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);

      // Migrate box from cache dir to document dir
      final oldDir = await getApplicationCacheDirectory();
      final oldBoxPath = '${oldDir.path}/savedBox.hive';
      final newBoxPath = '${dir.path}/savedBox.hive';
      if (await File(oldBoxPath).exists()) {
        await File(oldBoxPath).copy(newBoxPath);
      }
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
          final bodyContent = IndexedStack(
            index: _selectedIndex,
            children: [
              Consumer<InfoManager>(builder: (context, manager, child) {
                return PromptGenerationScreen();
              }),
              PromptConfigScreen(),
              I2IConfigScreen(),
              DirectorToolScreen(),
              SettingsScreen(),
            ],
          );

          final page = LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 640) {
                // Use BottomNavigationBar for narrow screens
                return Scaffold(
                  appBar: FlashingAppBar(),
                  body: bodyContent,
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onItemTapped,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    height: 64.0,
                    destinations: _navItems.map((item) {
                      return NavigationDestination(
                        icon: Icon(item['icon']),
                        label: context.tr(item['label']),
                      );
                    }).toList(),
                  ),
                );
              } else {
                // Use NavigationRail for wider screens
                return Scaffold(
                  appBar: FlashingAppBar(),
                  body: Row(
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: NavigationRail(
                                selectedIndex: _selectedIndex,
                                onDestinationSelected: _onItemTapped,
                                labelType: NavigationRailLabelType.all,
                                groupAlignment: -1.0, // 控制项目的对齐
                                destinations: _navItems.map((item) {
                                  return NavigationRailDestination(
                                    icon: Icon(item['icon']),
                                    label: Text(context.tr(item['label'])),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }),
                      VerticalDivider(
                        thickness: 2.0,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(
                        child: bodyContent, // Main content
                      ),
                    ],
                  ),
                );
              }
            },
          );

          final scope = PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              final now = DateTime.now();
              if (_lastPressed == null ||
                  now.difference(_lastPressed!) > const Duration(seconds: 2)) {
                _lastPressed = now;
                showInfoBar(context, context.tr("press_again_to_exit"));
              } else {
                SystemNavigator.pop();
              }
            },
            child: page,
          );

          return scope;
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _showFirstSetupDialog(String version) {
    const link = String.fromEnvironment("GITHUB_REPO_LINK");
    const email = String.fromEnvironment("EMAIL");
    final markdownMessage = context
        .tr("welcome_message_markdown")
        .replaceAll('{{link}}', link)
        .replaceAll('{{email}}', email);
    jumpToConfig() {
      Navigator.of(context).pop();
      setState(() {
        _selectedIndex = 4;
      });
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.tr('welcome_message_title')),
              content: MarkdownBody(
                data: markdownMessage,
                onTapLink: (text, href, title) {
                  if (href == '#') {
                    jumpToConfig();
                  } else if (href != null) {
                    launchUrl(Uri.parse(href));
                  }
                },
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      InfoManager().welcomeMessageVersion = version;
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
