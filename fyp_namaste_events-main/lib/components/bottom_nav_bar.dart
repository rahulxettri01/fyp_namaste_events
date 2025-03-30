import 'package:flutter/material.dart';

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
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/vendors');
            break;
          case 2:
            Navigator.pushNamed(context, '/create');
            break;
          case 3:
            Navigator.pushNamed(context, '/orders');
            break;
          case 4:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: "Vendors"),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create"),
        BottomNavigationBarItem(icon: Icon(Icons.download), label: "Orders"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
    );
  }
}