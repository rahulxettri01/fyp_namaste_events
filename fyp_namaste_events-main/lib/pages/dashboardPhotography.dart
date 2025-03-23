import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/AddInventory.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/Api/api_authentication.dart';
import 'InventoryDetailsPage.dart';

class PhotographyDashboard extends StatefulWidget {
  final String token;

  const PhotographyDashboard({required this.token, super.key});

  @override
  _PhotographyDashboardState createState() => _PhotographyDashboardState();
}

class _PhotographyDashboardState extends State<PhotographyDashboard> {
  late String userStatus;
  late String vendorName;
  List<dynamic> inventoryList = [];

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _fetchInventory();
  }

  void _decodeToken() {
    try {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
      userStatus = jwtDecodedToken['status'] ?? 'Unknown';
      vendorName = jwtDecodedToken['vendorName'] ?? 'Unknown Vendor';
    } catch (e) {
      userStatus = 'Unknown';
      vendorName = 'Unknown Vendor';
    }
  }

  // Fetch Inventory from API
  void _fetchInventory() async {
    try {
      List<dynamic> data = await Api.getInventory();
      print("Fetched data: $data");
      setState(() {
        inventoryList = data;
      });
    } catch (e) {
      print("Error fetching inventory: $e");
    }
  }

  // Sign-out function
  void _signOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Function to navigate to different pages
  void _navigateToPage(String page) async {
    switch (page) {
      case 'Dashboard':
        break;
      case 'Profile':
        break;
      case 'Settings':
        break;
      case 'Add Inventory':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddInventoryPage(token: widget.token),
          ),
        );

        if (result == true) {
          print("Inventory item added");
          _fetchInventory();
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photography Dashboard"),
      ),
      body: inventoryList.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: inventoryList.length,
        itemBuilder: (context, index) {
          final inventory = inventoryList[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                inventory['photographyName'] ?? "Unknown Item",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Price: ${inventory['price'] ?? 'N/A'}"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InventoryDetailsPage(inventory: inventory),
                  ),
                );
              },
            ),
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(vendorName),
              accountEmail: Text('Status: $userStatus'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard Home'),
              onTap: () {
                _navigateToPage('Dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Inventory'),
              onTap: () {
                _navigateToPage('Add Inventory');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}