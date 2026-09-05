import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'demo_pages.dart';
import 'floating_bottom_navigation.dart';

class PinterestDemoApp extends StatelessWidget {
  const PinterestDemoApp({super.key, this.homeCards = defaultHomeCards});

  final List<DemoCard> homeCards;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: kIsWeb ? 'NotoSansJP' : null,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          primary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: _DemoShell(homeCards: homeCards),
    );
  }
}

class _DemoShell extends StatefulWidget {
  const _DemoShell({required this.homeCards});

  final List<DemoCard> homeCards;

  @override
  State<_DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<_DemoShell> {
  var _selectedIndex = 0;

  void _selectTab(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                HomePage(cards: widget.homeCards),
                const SearchPage(),
                const ProfilePage(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNavigation(
              selectedIndex: _selectedIndex,
              onSelected: _selectTab,
            ),
          ),
        ],
      ),
    );
  }
}
