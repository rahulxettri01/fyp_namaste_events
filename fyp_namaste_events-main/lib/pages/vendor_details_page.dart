import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/services/Api/api_authentication.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp_namaste_events/utils/costants/api_constants.dart';

class VendorDetailsPage extends StatefulWidget {
  final Map<String, dynamic> vendor;
  final String token;

  const VendorDetailsPage({required this.vendor, required this.token, Key? key}) : super(key: key);

  @override
  _VendorDetailsPageState createState() => _VendorDetailsPageState();
}

class _VendorDetailsPageState extends State<VendorDetailsPage> {
  bool isLoading = false;
  String errorMessage = '';
  List<dynamic> images =[];

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      images = await Api.fetchImagesByEmail(widget.vendor['email']);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }


  Future<void> _updateVendorStatus(String status) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      print(widget.vendor['_id']);
      var url = Uri.parse('${APIConstants.baseUrl}vendor/update_vendor_status');
      print(url);
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": status, "id": widget.vendor['_id']}),  // Corrected line
      );

      if (response.statusCode == 200) {
        setState(() {
          widget.vendor['status'] = status;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to update vendor status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.vendor['vendorName']} Details"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text("Vendor Name"),
                    subtitle: Text(widget.vendor['vendorName']),
                  ),
                  ListTile(
                    title: Text("Email"),
                    subtitle: Text(widget.vendor['email']),
                  ),
                  ListTile(
                    title: Text("Phone"),
                    subtitle: Text(widget.vendor['phone']),
                  ),
                  ListTile(
                    title: Text("Category"),
                    subtitle: Text(widget.vendor['category']),
                  ),
                  ListTile(
                    title: Text("Status"),
                    subtitle: Text(widget.vendor['status']),
                  ),
                  // Display images
                  if (images.isNotEmpty)
                    Column(
                      children: images.map((image) {
                        return Image.network('${APIConstants.baseUrl}${image['filePath']}/${image['fileName']}');
                      }).toList(),
                    ),
                  // Add more fields as needed
                ],
              ),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _updateVendorStatus('verified'),
                  child: Text("Verify"),
                ),
                ElevatedButton(
                  onPressed: () => _updateVendorStatus('rejected'),
                  child: Text("Reject"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}