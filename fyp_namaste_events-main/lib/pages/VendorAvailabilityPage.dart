import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp_namaste_events/utils/costants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/Api/api_vendor_availability.dart';

class VendorAvailabilityPage extends StatefulWidget {
  final String vendorId;
  final String vendorType;
  final String token;

  const VendorAvailabilityPage({
    Key? key,
    required this.vendorId,
    required this.vendorType,
    required this.token,
  }) : super(key: key);

  @override
  _VendorAvailabilityPageState createState() => _VendorAvailabilityPageState();
}

class _VendorAvailabilityPageState extends State<VendorAvailabilityPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<dynamic> _availableSlots = [];
  bool _isLoading = false;
  late String vendorEmail; // Add this line

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    vendorEmail = jwtDecodedToken['email']; // Store email from token
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiVendorAvailability.getAvailableSlots(
        vendorEmail,
        widget.token,
      );
      print("Response from API: $response");

      // Directly use the response as it's already a List<dynamic>
      setState(() => _availableSlots = response);
      print("Available Slots: $_availableSlots");
    } catch (e) {
      print("Error loading slots: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load availability slots')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAvailabilitySlot() async {
    if (_rangeStart == null || _rangeEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date range')),
      );
      return;
    }

    // Calculate the difference in days
    final difference = _rangeEnd!.difference(_rangeStart!).inDays;

    // Validate minimum 5 days
    if (difference < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least 5 days')),
      );
      return;
    }

    // Validate maximum 30 days
    if (difference > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum selection is 30 days')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${APIConstants.baseUrl}api/vendorAvailability/create-slot'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode({
          'startDate': DateFormat('yyyy-MM-dd').format(_rangeStart!),
          'endDate': DateFormat('yyyy-MM-dd').format(_rangeEnd!),
          'category': widget.vendorType.toLowerCase() == 'photography'
              ? 'Photography'
              : widget.vendorType.toLowerCase() == 'venue'
                  ? 'Venue'
                  : widget.vendorType.toLowerCase() == 'decoration'
                      ? 'Decoration' // imp todo: check the spelling
                      : widget.vendorType,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                'Availability slot created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAvailableSlots(); // Refresh the list
        setState(() {
          _rangeStart = null;
          _rangeEnd = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                'Failed to create availability slot'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errorlol1: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Availability'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: RangeSelectionMode.enforced,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _rangeStart = start;
                _rangeEnd = end;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          SizedBox(height: 20),
          if (_rangeStart != null && _rangeEnd != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Selected Range: ${DateFormat('MMM dd').format(_rangeStart!)} - ${DateFormat('MMM dd').format(_rangeEnd!)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _createAvailabilitySlot,
            child: Text('Create Availability Slot'),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _availableSlots[index];
                      print("SlotLOL: $slot");
                      return ListTile(
                        title: Text(
                          '${DateFormat('MMM dd').format(DateTime.parse(slot['startDate']))} - ${DateFormat('MMM dd').format(DateTime.parse(slot['endDate']))}',
                        ),
                        subtitle: Text('Status: ${slot['status']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
