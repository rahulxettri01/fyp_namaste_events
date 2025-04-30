import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CanceledBookingsPage extends StatefulWidget {
  final List<dynamic> canceledBookings;

  CanceledBookingsPage({required this.canceledBookings});

  @override
  _CanceledBookingsPageState createState() => _CanceledBookingsPageState();
}

class _CanceledBookingsPageState extends State<CanceledBookingsPage> {
  List<dynamic> canceledBookings = [];
  String customerId = '';

  @override
  void initState() {
    super.initState();
    fetchCustomerId();
  }

  Future<void> fetchCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('customerID');
    if (id != null && id.isNotEmpty) {
      setState(() {
        customerId = id;
      });
      fetchCanceledBookings();
    } else {
      print('Customer ID not found in shared preferences');
    }
  }

  Future<void> fetchCanceledBookings() async {
    final String baseUrl = 'http://10.0.2.2:8000'; // Adjust the base URL as needed
    final String url = '$baseUrl/api/bookings/customer/$customerId/canceled'; // Endpoint for canceled bookings

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          canceledBookings = json.decode(response.body)['Bookings'];
        });
      } else {
        throw Exception('Failed to load canceled bookings');
      }
    } catch (e) {
      print('Error fetching canceled bookings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: canceledBookings.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/booking.png', // <-- Replace with your canceled image
                      height: 150,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "No Canceled Bookings Yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: canceledBookings.length,
              itemBuilder: (context, index) {
                final booking = canceledBookings[index];
                final artist = booking['artistID'];
                final availability = booking['availabilityID'];
                final service = booking['serviceID'];

                DateTime dateTime;
                try {
                  String dateStr = availability['date'];
                  String startTime = availability['startTime'] ?? availability['time'] ?? '';
                  String combined = "${dateStr.split('T').first}T${startTime.isNotEmpty ? startTime : '00:00'}:00Z";
                  dateTime = DateTime.parse(combined);
                } catch (e) {
                  dateTime = DateTime.now();
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
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Canceled',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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