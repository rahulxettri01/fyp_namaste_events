import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/services/Api/bookingService.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final double price;

  const BookingPage({
    Key? key,
    required this.vendorId,
    required this.vendorName,
    required this.price,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  final TextEditingController _guestCountController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final bookingData = {
        'vendorId': widget.vendorId,
        'eventType': 'Event',
        'eventDate': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'guestCount': int.parse(_guestCountController.text),
        'requirements': _requirementsController.text,
        'venue': _venueController.text,
        'totalAmount': widget.price,
      };

      try {
        final result = await BookingService.createBooking(bookingData);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking created successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Booking failed')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Vendor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking for ${widget.vendorName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(selectedDate == null
                    ? 'Select Event Date'
                    : 'Event Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guestCountController,
                decoration: const InputDecoration(
                  labelText: 'Number of Guests',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of guests';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter venue details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _requirementsController,
                decoration: const InputDecoration(
                  labelText: 'Special Requirements',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Total Amount: Rs.${widget.price}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}