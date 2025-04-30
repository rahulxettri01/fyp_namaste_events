import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'bottomtab/bottomtab.dart';

class CusBookingPage extends StatefulWidget {
  const CusBookingPage({super.key});

  @override
  State<CusBookingPage> createState() => _CusBookingPageState();
}

class _CusBookingPageState extends State<CusBookingPage> {
  List bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/bookings/allBookings'), // Correct URL
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers here
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          bookings = json.decode(response.body)['Bookings'];
          isLoading = false;
        });
      } else {
        // Handle error
        print('Failed to load bookings. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Failed to load bookings. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Booking ${bookings[index]['_id']}'),
            subtitle: Text('Customer ID: ${bookings[index]['_id']}'),
          );
        },
      ),
      bottomNavigationBar: CusBottomTabs(
        currentIndex: 3,
      ),
    );
  }
}