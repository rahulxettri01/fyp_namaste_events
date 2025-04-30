import 'package:flutter/material.dart';
import '../bottomtab/bottomtab.dart';
import 'CanceledBookings.dart';
import 'UpcommingBooking.dart';
import 'completedBooking.dart'; // Assuming you already have this file

void main() {
  runApp(MyBookingsApp());
}

class MyBookingsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyBookingsPage(),
    );
  }
}

class MyBookingsPage extends StatefulWidget {
  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> canceledBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _selectedIndex = 2; // Calendar Icon selected

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Canceled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UpcomingBookingsPage(
            onCancelBooking: (booking) {
              setState(() {
                canceledBookings.add(booking);
              });
            },
          ),
          CompletedBookingsPage(),
          CanceledBookingsPage(canceledBookings: canceledBookings),
        ],
      ),
      bottomNavigationBar: CusBottomTabs(currentIndex: _selectedIndex),
    );
  }
}