import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/ProfilePage.dart';
import 'package:fyp_namaste_events/pages/VendorsPage.dart';
import 'package:fyp_namaste_events/pages/home_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0; // Track the selected index

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex, // Set the current index
      onTap: (index) {
        setState(() {
          _currentIndex = index; // Update the state when an item is tapped
        });
        // Navigate to the corresponding page based on the index
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VendorsPage()),
            );
            break;
          case 2:
            Navigator.pushNamed(context, '/orders');
            break;
          case 3:
            Navigator.pushNamed(context, '/notifications');
            break;
          case 4:
            // Navigate to the profile page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: "Vendors"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Bookings"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    );
  }
}
