import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';
import 'package:fyp_namaste_events/utils/costants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardPage extends StatefulWidget {
  final String token;

  const AdminDashboardPage({required this.token, Key? key}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<dynamic> vendors = [];

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    final response = await http.get(
      Uri.parse('${APIConstants.baseUrl}/admin/get_vendors'),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      },
    );
  print(response);
    if (response.statusCode == 200) {
      setState(() {
        vendors = json.decode(response.body);
      });
    } else {
      // Handle error
    }
  }

  Future<void> _verifyVendor(String vendorId) async {
    final response = await http.get(
      Uri.parse('${APIConstants.baseUrl}/admin/get_vendor'),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      },

    );

    if (response.statusCode == 200) {
      _fetchVendors(); // Refresh the vendor list
    } else {
      // Handle error
    }
  }

  void _signOut() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
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
      body: ListView.builder(
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return ListTile(
            title: Text(vendor['vendorName']),
            subtitle: Text(vendor['email']),
            trailing: vendor['status'] == 'verified'
                ? Icon(Icons.verified, color: Colors.green)
                : ElevatedButton(
              onPressed: () => _verifyVendor(vendor['_id']),
              child: Text("Verify"),
            ),
          );
        },
      ),
    );
  }
}