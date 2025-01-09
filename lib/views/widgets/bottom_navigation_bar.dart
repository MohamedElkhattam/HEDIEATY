import 'package:flutter/material.dart';
import 'package:hedieaty/views/Screens/event_list_screen.dart';
import 'package:hedieaty/views/Screens/home_screen.dart';

import 'package:hedieaty/models/model/user_model.dart';

class MainNavigation extends StatefulWidget {
  final UserModel user;
  const MainNavigation({super.key, required this.user});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(user: widget.user),
      EventListScreen(userId: widget.user.firestoreId!),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('bottom_navigation_bar'),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            key:  Key('go_to_events'),
            icon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
