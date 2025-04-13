import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/vendor_detail_page.dart';

class VendorListPage extends StatelessWidget {
  final List<dynamic> vendors;
  final String category;

  const VendorListPage({
    Key? key,
    required this.vendors,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      vendor['images'] != null && vendor['images'].isNotEmpty
                          ? vendor['images'][0]['fullUrl']
                          : 'https://via.placeholder.com/150',
                    ),
                  ),
                ),
              ),
              title: Text(
                _getVendorName(vendor),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    vendor['address'] ?? 'No address provided',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getPriceText(vendor),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorDetailPage(
                      vendorData: vendor,
                      vendorType: _getVendorType(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getVendorName(Map<String, dynamic> vendor) {
    switch (category.toLowerCase()) {
      case 'venue':
        return vendor['venueName'] ?? 'Unknown Venue';
      case 'photographer':
        return vendor['photographyName'] ?? 'Unknown Photographer';
      case 'food':
        return vendor['foodServiceName'] ?? 'Unknown Food Service';
      case 'decorator':
        return vendor['decoratorName'] ?? 'Unknown Decorator';
      default:
        return 'Unknown Vendor';
    }
  }

  String _getPriceText(Map<String, dynamic> vendor) {
    switch (category.toLowerCase()) {
      case 'venue':
        return 'Rs ${vendor['price'] ?? '0'} per plate';
      case 'photographer':
        return 'Rs ${vendor['price'] ?? '0'} per event';
      case 'food':
        return 'Rs ${vendor['price'] ?? '0'} per plate';
      case 'decorator':
        return 'Rs ${vendor['price'] ?? '0'} per event';
      default:
        return 'Rs ${vendor['price'] ?? '0'}';
    }
  }

  String _getVendorType() {
    switch (category.toLowerCase()) {
      case 'venue':
        return 'venue';
      case 'photographer':
        return 'photographer';
      case 'food':
        return 'food';
      case 'decorator':
        return 'decorator';
      default:
        return 'vendor';
    }
  }
}