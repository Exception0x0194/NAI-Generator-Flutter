import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/generator_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/prompt_config_screen.dart';
import 'models/info_manager.dart';
import 'generated/l10n.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => InfoManager(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink.shade700),
          useMaterial3: true,
          fontFamily: 'Noto'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
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
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future _loadInitialInfo() async {
    var jsonData =
        json.decode(await rootBundle.loadString('json/example.json'));
    InfoManager().fromJson(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
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
                SettingsScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(Icons.create),
                  label: S.of(context).generation,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.visibility),
                  label: S.of(context).prompt_config,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: S.of(context).settings,
                )
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
