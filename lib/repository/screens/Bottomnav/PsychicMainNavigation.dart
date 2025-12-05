import 'package:flutter/material.dart';
import 'package:psychics/repository/PsychicProfile/FreelancerProfileScreen.dart';
import 'package:psychics/repository/screens/MyBooking/PsychicBookingsScreen.dart';


class PsychicMainNavigation extends StatefulWidget {
  final Widget profileScreen;  // <-- NEW

  const PsychicMainNavigation({super.key, required this.profileScreen});



  @override
  State<PsychicMainNavigation> createState() => _PsychicMainNavigationState();
}


class _PsychicMainNavigationState extends State<PsychicMainNavigation> {
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      widget.profileScreen,   // <-- SHOW PSYCHIC PROFILE HERE
      const Center(child: Text("Calls Page Coming Soon")),
      const PsychicBookingsScreen(),
      const Center(child: Text("Profile Page Coming Soon")),
    ];


    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: "Psychics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: "Calls",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
