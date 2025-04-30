import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../bottomtab/explore_page.dart';

class CompletedBookingsPage extends StatefulWidget {
  @override
  _CompletedBookingsPageState createState() => _CompletedBookingsPageState();
}

class _CompletedBookingsPageState extends State<CompletedBookingsPage> {
  List<dynamic> completedBookings = [];
  String customerId = '';

  @override
  void initState() {
    super.initState();
    fetchCustomerId();
  }

  Future<void> fetchCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getString('customerID') ?? 'YOUR_CUSTOMER_ID';
    });
    fetchCompletedBookings();
  }

  Future<void> fetchCompletedBookings() async {
    final String baseUrl = 'http://10.0.2.2:8000';
    final String url = '$baseUrl/api/bookings/customer/$customerId?status=completed';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          completedBookings = json.decode(response.body)['Bookings'];
        });
      } else {
        throw Exception('Failed to load completed bookings');
      }
    } catch (e) {
      print('Error fetching completed bookings: $e');
    }
  }

  void handleReBook(dynamic booking) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExplorePage()),
    );
  }



  void handleAddReview(dynamic booking) async {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        booking: booking,
        customerId: customerId,
        onReviewSubmitted: fetchCompletedBookings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: completedBookings.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/booking.png',
                height: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                "No Completed Bookings Yet.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Check again after your first appointment!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.pink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: completedBookings.length,
        itemBuilder: (context, index) {
          final booking = completedBookings[index];
          final artist = booking['artistID'];
          final availability = booking['availabilityID'];
          final service = booking['serviceID'];

          DateTime dateTime;
          try {
            String combined =
                "${availability['date'].split('T').first}T${availability['startTime']}:00Z";
            dateTime = DateTime.parse(combined);
          } catch (e) {
            print('Date parsing error: $e');
            dateTime = DateTime.now();
          }

          String formattedDate =
          DateFormat('EEEE, MMMM d - hh:mma').format(dateTime);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Short divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Divider(height: 1, thickness: 1),
                ),
                // Artist info row
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          artist['profilePictureUrl'] ??
                              'https://via.placeholder.com/100',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artist['name'] ?? 'Artist 1',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service['name'] ?? 'Hair Stylist',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Short divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Divider(height: 1, thickness: 1),
                ),
                // Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => handleReBook(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F2F4),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Re-Book'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => handleAddReview(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF56C1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Add Review'),
                        ),
                      ),
                    ],
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

// Add this widget at the end of the file (or in a separate file if you prefer)
class AddReviewDialog extends StatefulWidget {
  final dynamic booking;
  final String customerId;
  final VoidCallback onReviewSubmitted;

  const AddReviewDialog({
    Key? key,
    required this.booking,
    required this.customerId,
    required this.onReviewSubmitted,
  }) : super(key: key);

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  Future<void> submitReview() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final url = 'http://10.0.2.2:8000/api/reviews';
    final body = jsonEncode({
      'customerID': widget.customerId,
      'artistID': widget.booking['artistID']['_id'],
      'serviceID': widget.booking['serviceID']['_id'],
      'review': _reviewController.text.trim(),
      'rating': _rating,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Rating and review submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        widget.onReviewSubmitted();
        Navigator.of(context).pop();
      } else {
        setState(() {
          _error = jsonDecode(response.body)['error'] ?? 'Failed to submit review';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Give a Review',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, size: 20),
                )
              ],
            ),
            SizedBox(height: 15),

            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 10),

            // Text input
            TextField(
              controller: _reviewController,
              minLines: 3,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write Your Review…',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              ),

            SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6DC3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isSubmitting ? null : submitReview,
                child: _isSubmitting
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text('Send Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
