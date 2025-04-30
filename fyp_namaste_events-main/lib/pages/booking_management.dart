import 'package:flutter/material.dart';
import 'package:roopkatha/admin/sidebar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart' as ex;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:html' as html; // For web

class BookingManagement extends StatefulWidget {
  const BookingManagement({super.key});

  @override
  State<BookingManagement> createState() => _BookingManagementState();
}

class _BookingManagementState extends State<BookingManagement> {
  List<dynamic> bookings = [];
  List<dynamic> allBookings = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/api/bookings'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allBookings = data['Bookings'] ?? [];
          bookings = allBookings;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch bookings: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _filterBookings(String query) {
    setState(() {
      searchQuery = query;
      bookings = allBookings.where((booking) {
        final customerName = (booking['customerID']?['name'] ?? '').toString().toLowerCase();
        final search = query.toLowerCase();
        return customerName.contains(search);
      }).toList();
    });
  }

  Widget _buildStatusChip(String? status) {
    String label = (status ?? '').toLowerCase();
    Color bg;
    Color fg; 
    switch (label) {
      case 'completed':
        bg = Color(0xFFE9F9EE);
        fg = Color(0xFF27AE60);
        break;
      case 'active':
        bg = Color(0xFFE6F4FF);
        fg = Color(0xFF2D9CDB);
        break;
      case 'cancelled':
        bg = Color(0xFFFFE9E9);
        fg = Color(0xFFEB5757);
        break;
      default:
        bg = Color.fromARGB(255, 235, 93, 93);
        fg = Color.fromARGB(255, 255, 255, 255);
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      drawer: isWideScreen ? null : AdminSidebar(),
      body: isWideScreen
          ? Row(
              children: [
                SizedBox(
                  child: AdminSidebar(),
                ),
                Expanded(
                  child: _buildBookingManagementContent(),
                ),
              ],
            )
          : _buildBookingManagementContent(),
    );
  }

  // Export to Excel
  Future<void> _exportToExcel() async {
    var excel = ex.Excel.createExcel();
    ex.Sheet sheetObject = excel['Bookings'];
    // Header
    sheetObject.appendRow([
      'Booking ID', 'Customer', 'Date', 'Service', 'Amount', 'Payment Method', 'Status'
    ]);
    // Data
    for (var booking in bookings) {
      String dateStr = '';
      if (booking['createdAt'] != null) {
        final date = DateTime.tryParse(booking['createdAt']);
        if (date != null) {
          dateStr = "${_monthShort(date.month)} ${date.day}, ${date.year}";
        }
      }
      sheetObject.appendRow([
        booking['_id'] ?? '',
        booking['customerID']?['name'] ?? '',
        dateStr,
        booking['serviceID']?['name'] ?? '',
        booking['price'] ?? '',
        booking['paymentMethod'] ?? '',
        booking['status'] ?? '',
      ]);
    }
    final fileBytes = excel.encode();
    if (kIsWeb) {
      final content = base64Encode(fileBytes!);
      final anchor = html.AnchorElement(
          href: "data:application/octet-stream;charset=utf-16le;base64,$content")
        ..setAttribute("download", "bookings.xlsx")
        ..click();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported bookings.xlsx')),
      );
    } else {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        String outputFile = "${directory!.path}/bookings.xlsx";
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported bookings.xlsx')),
        );
      }
    }
  }

  Widget _buildBookingManagementContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add export button here
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bookings",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _exportToExcel,
                  icon: Icon(Icons.download, size: 18),
                  label: Text("Export"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF7F7FB),
                    foregroundColor: Color(0xFF7A7A7A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[500], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search for Service",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: 15),
                      onChanged: (value) {
                        _filterBookings(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 24,
                            headingRowHeight: 48,
                            dataRowHeight: 56,
                            headingRowColor: MaterialStateProperty.all(Color(0xFFFFF0F7)), // light pink
                            border: TableBorder(
                              horizontalInside: BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            columns: [
                              DataColumn(
                                label: SizedBox(
                                  width: 180, // Increased from 120 to 180
                                  child: Text(
                                    'ID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Service',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Amount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 140,
                                  child: Text(
                                    'Payment Method',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: bookings.map((booking) {
                              // Format date
                              String dateStr = '';
                              if (booking['createdAt'] != null) {
                                final date = DateTime.tryParse(booking['createdAt']);
                                if (date != null) {
                                  dateStr = "${_monthShort(date.month)} ${date.day}, ${date.year}";
                                }
                              }
                              // Use status field for status chip
                              String status = booking['status']?.toString().toLowerCase() ?? '';
                              return DataRow(
                                cells: [
                                  DataCell(SizedBox(
                                    width: 220,
                                    child: Text(
                                      booking['_id'] ?? '',
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 120,
                                    child: Text(
                                      dateStr,
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 120,
                                    child: Text(
                                      booking['serviceID']?['name'] ?? '',
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 120,
                                    child: Text(
                                      "Rs. ${booking['price'] ?? ''}",
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 140,
                                    child: Text(
                                      booking['paymentMethod'] ?? '',
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 120,
                                    child: _buildStatusChip(status),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  String _monthShort(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
