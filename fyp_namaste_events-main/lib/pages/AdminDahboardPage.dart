import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';
import 'package:fyp_namaste_events/utils/costants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'vendor_details_page.dart'; // Import the new page

class AdminDashboardPage extends StatefulWidget {
  final String token;

  const AdminDashboardPage({required this.token, Key? key}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<dynamic> vendors = [];
  bool isLoading = true;
  String errorMessage = '';
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      var url = Uri.parse('${APIConstants.baseUrl}superadmin/get_vendors');
      print(url);
      final response = await http.get(
          url
      );
      print(response);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          setState(() {
            vendors = responseData['data'];
            isLoading = false;
          });
        } else {
          print(responseData['data']);
          setState(() {
            isLoading = false;
            errorMessage = 'No data found';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch vendors: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _verifyVendor(String vendorId) async {
    try {
      final response = await http.put(
        Uri.parse('${APIConstants.baseUrl}admin/verify_vendor/$vendorId'),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        _fetchVendors(); // Refresh the vendor list
      } else {
        print('Failed to verify vendor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void _signOut() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchVendors,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return ListTile(

            title: Text(vendor['vendorName']),
            subtitle: Text(vendor['email']),
            trailing: ElevatedButton(
              onPressed: () {
                vendorJWT(vendor);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorDetailsPage(vendor: vendor, token: '',),
                  ),
                );
              },
              child: Text("Details"),
            ),
          );
        },
      ),
    );
  }

   vendorJWT(vendor) {

    // prefs.setString("CurrentVendor", );
  }
}