import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roopkatha/UI/pages/customer/bottomtab/cus_chat_page.dart';
import 'package:roopkatha/UI/pages/customer/bottomtab/cus_profile_page.dart';
import '../Booking/MyBooking.dart';
import 'explore_page.dart';
import 'home_page.dart';

// Cupertino icons
const String iconFont = 'CupertinoIcons';
const String iconFontPackage = 'cupertino_icons';

const IconData calendar = IconData(
  0xf5b0,
  fontFamily: iconFont,
  fontPackage: iconFontPackage,
);

const IconData chatBubbleText = IconData(
  0xf8bf,
  fontFamily: iconFont,
  fontPackage: iconFontPackage,
);

// Material icons
const IconData explore = IconData(0xe248, fontFamily: 'MaterialIcons');

class CusBottomTabs extends StatefulWidget {
  int currentIndex;
  CusBottomTabs({super.key, required this.currentIndex});

  @override
  State<CusBottomTabs> createState() => _CusBottomTabsState();
}

class _CusBottomTabsState extends State<CusBottomTabs> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
  }

  void onTap(int index) {
    currentIndex = index;
    switch (currentIndex) {
      case 0:
        Get.off(() => CusHomePage()); // Removes transition animation
        break;
      case 1:
        Get.off(() => ExplorePage()); // Removes transition animation
        break;
      case 2:
        Get.off(() => MyBookingsApp()); // Removes transition animation
        break;
      case 3:
        Get.off(() => CusChatPage()); // Removes transition animation
        break;
      case 4:
        Get.off(() => CustomerProfile()); // Removes transition animation
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the bottom bar
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1), // Top border
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white, // Bottom bar background color
        unselectedFontSize: 0,
        selectedFontSize: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: Color(0xFFFF6FCA), // Changed to pink
        unselectedItemColor: Colors.grey, // Changed to grey
        showSelectedLabels: false, // Hide selected labels
        showUnselectedLabels: false, // Hide unselected labels
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(explore, size: 30),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(calendar, size: 30),
            label: "Booking",
          ),
          BottomNavigationBarItem(
            icon: Icon(chatBubbleText, size: 30),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}