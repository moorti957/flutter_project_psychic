import 'package:flutter/material.dart';
import 'package:psychics/repository/screens/Chat/ChatListScreen.dart';
import 'package:psychics/repository/screens/Dashboard/Dashboardscreen.dart';
import 'package:psychics/repository/screens/MyBooking/MyBookingsScreen.dart';
import 'package:psychics/repository/screens/MyProfile/MyProfileScreen.dart';
import 'package:psychics/repository/screens/PsychicList/PsychicListScreen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    DashboardScreen(),
    PsychicListScreen(),
    MyBookingsScreen(),
    MyProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,   // 👈 TEXT ALWAYS SHOW
        showSelectedLabels: true,     // 👈 TEXT ALWAYS SHOW
        onTap: (index) {
          setState(() => _currentIndex = index);
        },

        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: Icon(Icons.home, size: 28),
            ),
          ),

          BottomNavigationBarItem(
            label: "Psychics",
            icon: Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: Icon(Icons.person_search, size: 28),
            ),
          ),

          BottomNavigationBarItem(
            label: "Chat",
            icon: Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: Icon(Icons.chat, size: 28),
            ),
          ),

          BottomNavigationBarItem(
            label: "Profile",
            icon: Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: Icon(Icons.person, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
