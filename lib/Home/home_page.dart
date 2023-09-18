import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/tab_home/tab_home.dart';
import 'package:hiking_platform/Home/tab_profile/profile_index.dart';
import 'package:postgres/src/connection.dart';

import '../query.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.connection, required this.user})
      : super(key: key);

  final PostgreSQLConnection connection;
  final User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late User user;

  late List<Widget> tabViewList;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    tabViewList = [
      TabHome(user: user, connection: widget.connection),
      TabProfile(user: user, connection: widget.connection),
    ];
    pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: tabViewList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
