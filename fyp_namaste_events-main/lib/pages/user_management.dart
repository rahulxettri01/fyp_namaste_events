import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:roopkatha/admin/sidebar.dart';
import 'package:excel/excel.dart' as ex;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:html' as html; // For web

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  List<dynamic> customers = [];
  List<dynamic> allCustomers = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/customer/all'),
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allCustomers = data['customers'];
          customers = allCustomers;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch customers: ${response.statusCode}';
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

  void _filterCustomers(String query) {
    setState(() {
      searchQuery = query;
      customers = allCustomers.where((customer) {
        final name = (customer['name'] ?? '').toString().toLowerCase();
        final search = query.toLowerCase();
        return name.contains(search);
      }).toList();
    });
  }

  Future<void> _deleteCustomer(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8000/api/customer/delete/$id'),
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          customers.removeWhere((c) => c['_id'] == id);
          allCustomers.removeWhere((c) => c['_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete customer')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _editCustomer(dynamic customer) {
    // Placeholder for edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit feature coming soon!')),
    );
  }

  // Export to Excel
  Future<void> _exportToExcel() async {
    var excel = ex.Excel.createExcel();
    ex.Sheet sheetObject = excel['Customers'];
    // Header
    sheetObject.appendRow([
      'Name', 'Email', 'Phone', 'Gender', 'Address', 'Status'
    ]);
    // Data
    for (var customer in customers) {
      sheetObject.appendRow([
        customer['name'] ?? '',
        customer['email'] ?? '',
        customer['phoneNo'] ?? '',
        customer['gender'] ?? '',
        customer['address'] ?? '',
        customer['status'] ?? '',
      ]);
    }
    final fileBytes = excel.encode();
    if (kIsWeb) {
      final content = base64Encode(fileBytes!);
      final anchor = html.AnchorElement(
          href: "data:application/octet-stream;charset=utf-16le;base64,$content")
        ..setAttribute("download", "customers.xlsx")
        ..click();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported customers.xlsx')),
      );
    } else {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        String outputFile = "${directory!.path}/customers.xlsx";
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported customers.xlsx')),
        );
      }
    }
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
                  child: _buildUserManagementContent(),
                ),
              ],
            )
          : _buildUserManagementContent(),
    );
  }

  Widget _buildUserManagementContent() {
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
                  "Customers",
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
                        hintText: "Search for Customer",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: 15),
                      onChanged: (value) {
                        _filterCustomers(value);
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
                            columnSpacing: 32,
                            headingRowHeight: 48,
                            dataRowHeight: 56,
                            headingRowColor: MaterialStateProperty.all(Color(0xFFF7F7FB)),
                            border: TableBorder(
                              horizontalInside: BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            columns: [
                              DataColumn(
                                label: SizedBox(
                                  width: 140,
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 200,
                                  child: Text(
                                    'Email',
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
                                    'Date of Birth',
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
                                    'PhoneNo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 80,
                                  child: Text(
                                    'Gender',
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
                                    'Action',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: customers.map((customer) {
                              return DataRow(
                                cells: [
                                  DataCell(SizedBox(
                                    width: 140,
                                    child: Text(
                                      customer['name'] ?? '',
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 200,
                                    child: Text(
                                      customer['email'] ?? '',
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 120,
                                    child: Text(
                                      customer['dob'] != null
                                          ? customer['dob'].toString().substring(0, 10)
                                          : '',
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 120,
                                    child: Text(
                                      customer['phoneNo'] ?? '',
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 80,
                                    child: Text(
                                      customer['gender'] ?? '',
                                      style: TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 140,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () => _editCustomer(customer),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Color(0xFFD1B1F8)),
                                            backgroundColor: Color(0xFFF7F7FB),
                                            foregroundColor: Color(0xFF7A7A7A),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            minimumSize: Size(40, 36),
                                            padding: EdgeInsets.symmetric(horizontal: 16),
                                          ),
                                          child: Text("Edit"),
                                        ),
                                        SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed: () => _deleteCustomer(customer['_id']),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Color(0xFFF8B1B1)),
                                            backgroundColor: Color(0xFFFDF6F6),
                                            foregroundColor: Color(0xFF7A7A7A),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            minimumSize: Size(40, 36),
                                            padding: EdgeInsets.symmetric(horizontal: 16),
                                          ),
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    ),
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
}
