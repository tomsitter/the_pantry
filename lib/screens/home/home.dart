import 'package:flutter/material.dart';
import 'package:the_pantry/screens/grocery/grocery.dart';
import 'package:the_pantry/screens/pantry/pantry.dart';
import 'package:the_pantry/screens/home/local_widgets/app_drawer.dart';

import '../../constants.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  final List<Color> _pageColors = [
    AppTheme.blue,
    AppTheme.redBrown,
  ];
  final List<String> _pageName = ['My Grocery List', 'My Pantry'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _pageColors[_selectedTab],
          title: Text(
            _pageName[_selectedTab],
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: AppTheme.paleYellow,
            tabs: const [
              Tab(icon: Icon(Icons.shopping_cart)),
              Tab(icon: Icon(Icons.home)),
            ],
            onTap: (int index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
        ),
        drawer: AppDrawer(color: _pageColors[_selectedTab]),
        body: TabBarView(
          children: [
            GroceryScreen(color: _pageColors[0]),
            PantryScreen(color: _pageColors[1]),
          ],
        ),
      ),
    );
  }
}
