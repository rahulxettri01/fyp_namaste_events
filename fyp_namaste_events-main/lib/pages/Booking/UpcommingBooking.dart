import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../bottomtab/explore_page.dart';

class UpcomingBookingsPage extends StatefulWidget {
  final Function(dynamic booking) onCancelBooking;

  UpcomingBookingsPage({required this.onCancelBooking});

  @override
  _UpcomingBookingsPageState createState() => _UpcomingBookingsPageState();
}

class _UpcomingBookingsPageState extends State<UpcomingBookingsPage> {
  List<dynamic> bookings = [];
  String customerId = '';

  @override
  void initState() {
    super.initState();
    fetchCustomerId();
  }

  Future<void> fetchCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getString('customerID') ?? '';
    });
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final String baseUrl = 'http://10.0.2.2:8000';
    final String url = '$baseUrl/api/bookings/customer/$customerId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          bookings = json.decode(response.body)['Bookings'];
        });
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final String baseUrl = 'http://10.0.2.2:8000';
    final String url = '$baseUrl/api/bookings/delete/$bookingId';

    try {
      final response = await http.patch(Uri.parse(url)); // <-- Use PATCH instead of DELETE

      if (response.statusCode == 200) {
        setState(() {
          final canceledBooking = bookings.firstWhere((booking) => booking['_id'] == bookingId);
          bookings.removeWhere((booking) => booking['_id'] == bookingId);
          widget.onCancelBooking(canceledBooking);
        });
      } else {
        print('Failed to cancel booking: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to cancel booking');
      }
    } catch (e) {
      print('Error canceling booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: bookings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "No Upcoming Bookings Yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Get.to(() => ExplorePage());
              },
              child: Text(
                "Book your first makeup appointment now!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.pink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final artist = booking['artistID'];
          final availability = booking['availabilityID'];
          final service = booking['serviceID'];

          DateTime dateTime;

          try {
            // Safely combine date and startTime into ISO string and parse
            String dateStr = availability['date']; // e.g., "2025-04-06T00:00:00.000Z"
            String startTime = availability['startTime']; // e.g., "14:30"

            // Ensure only the date portion is used from 'date'
            String dateOnly = dateStr.split('T').first;

            // Combine properly
            String combined = "${availability['date']}T${availability['startTime']}:00Z";

            // Parse to DateTime
            dateTime = DateTime.parse(combined);
          } catch (e) {
            print('Date parsing error: $e');
            dateTime = DateTime.now(); // fallback
          }

          String formattedDate = DateFormat('EEEE, MMMM d - hh:mma').format(dateTime);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        artist['profilePictureUrl'] ?? 'https://via.placeholder.com/100',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artist['name'] ?? 'Artist',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service['name'] ?? 'Service Name',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rs. ${service['price'] ?? '0'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.pink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => cancelBooking(booking['_id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red, // Text color
                        side: const BorderSide(color: Colors.red), // Border color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}
