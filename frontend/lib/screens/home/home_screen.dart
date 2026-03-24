import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebar.dart';
import 'package:frontend/screens/home/home_page.dart';
import 'package:frontend/screens/pantry/pantry_page.dart';
import 'package:frontend/screens/shoppingList/shopping_list_page.dart';
import 'package:frontend/screens/user/user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    PantryPage(),
    ShoppingListPage(),
    UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
