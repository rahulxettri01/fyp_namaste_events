import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fyp_namaste_events/services/Api/bookingService.dart';

class VendorAvailabilityPage extends StatefulWidget {
  final String vendorId;
  final String vendorType; // Add this

  const VendorAvailabilityPage({
    Key? key,
    required this.vendorId,
    required this.vendorType,
  }) : super(key: key);

  @override
  State<VendorAvailabilityPage> createState() => _VendorAvailabilityPageState();
}

class _VendorAvailabilityPageState extends State<VendorAvailabilityPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, bool> _availabilityMap = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() {
      isLoading = true;
    });

    try {
      final availability =
          await BookingService.getVendorAvailability(widget.vendorId);
      setState(() {
        _availabilityMap = Map.fromEntries(
          availability.map((a) {
            // Parse the date string from the response
            final date = DateTime.parse(a['date']);
            return MapEntry(DateTime(date.year, date.month, date.day),
                a['isAvailable'] as bool);
          }),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading availability: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleAvailability(DateTime date) async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentAvailability = _availabilityMap[date] ?? true;
      await BookingService.updateVendorAvailability(
        widget.vendorId,
        date,
        !currentAvailability,
        widget.vendorType,
      );

      setState(() {
        _availabilityMap[date] = !currentAvailability;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!currentAvailability
              ? 'Date marked as available'
              : 'Date marked as unavailable'),
          backgroundColor: !currentAvailability ? Colors.green : Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating availability: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String get _getTitle {
    switch (widget.vendorType) {
      case 'venue':
        return 'Venue Availability';
      case 'decoration':
        return 'Decoration Service Availability';
      case 'photography':
        return 'Photography Service Availability';
      default:
        return 'Manage Availability';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _toggleAvailability(selectedDay);
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _availabilityMap[date] == false
                              ? Colors.red.withOpacity(0.3)
                              : null,
                        ),
                        child: Text(date.day.toString()),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tap on a date to mark as unavailable/available',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
    );
  }
}
