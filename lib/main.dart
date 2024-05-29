import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/generator_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/prompt_config_screen.dart';
import 'models/info_manager.dart';

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

  @override
  void initState() {
    super.initState();
    _loadInitialInfo();
  }

  static final List<Widget> _widgetOptions = <Widget>[
    Consumer<InfoManager>(builder: (context, manager, child) {
      // ignore: prefer_const_constructors
      return PromptGenerationScreen();
    }),
    // const PromptGenerationScreen(),
    const PromptConfigScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Generation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'Prompt Config',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _loadInitialInfo() async {
    var jsonData =
        json.decode(await rootBundle.loadString('json/example.json'));
    InfoManager().fromJson(jsonData);
  }
}
